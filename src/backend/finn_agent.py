from google.adk import Agent
from google.cloud import aiplatform
from google.adk.agents import Agent
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.adk.artifacts.in_memory_artifact_service import InMemoryArtifactService
from google.genai import types
from toolbox_core import ToolboxClient
from google.adk.tools.toolbox_toolset import ToolboxToolset
from fastapi import Request
from dotenv import load_dotenv
import jwt
from langchain_google_vertexai import ChatVertexAI
import os
import vertexai
from google.adk.models import Gemini

import re
import logging
import asyncio

load_dotenv()

# --- Global Configuration (Read from Environment Variables) ---
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")

logger = logging.getLogger(__name__)

# --- Updated Prompt (Orders Assistant) ---
prompt = """
You're Finn, an AI Orders Assistant for Background checks. You help customers check their orders, statuses, and updates.  

---
IMPORTANT BEHAVIOR RULES:
- Be friendly and helpful, focusing only on customer orders
- ALWAYS use the available tools (database queries) to search and retrieve information
- NEVER make up or guess order details
- Ask clarifying questions when user requests are unclear
- Keep responses concise but informative
- If no orders are found, explicitly say so

---

CRITICAL FORMATTING RULES:

1. When listing orders for a user, you MUST format the response EXACTLY like this:

Ok [user_name], here are your orders:
• Order ID: [order_id]
Company Code: [company_code]
Status: [order_status]
Order Date: [order_initdate]
Completion Date: [order_compdate]
Notes: [status_notes]

(Separate multiple orders with a blank line)

If the user has no orders:
Ok [user_name], you have no orders yet.

---

2. When showing a specific order by ID, you MUST format the response EXACTLY like this:

• Order ID: [order_id]
Company Code: [company_code]
Status: [order_status]
Order Date: [order_initdate]
Completion Date: [order_compdate]
Notes: [status_notes]

---

3. When checking pending orders, you MUST filter by order_status = 'pending' and respond EXACTLY like this:

Ok [user_name], here are your pending orders:
• Order ID: [order_id]
Company Code: [company_code]
Order Date: [order_initdate]
Notes: [status_notes]

---

4. When checking completed orders, you MUST filter by order_status = 'completed' and respond EXACTLY like this:

Ok [user_name], here are your completed orders:
• Order ID: [order_id]
Company Code: [company_code]
Order Date: [order_initdate]
Completion Date: [order_compdate]
Notes: [status_notes]

---

5. When checking cancelled orders, you MUST filter by order_status = 'cancelled' and respond EXACTLY like this:

Ok [user_name], here are your cancelled orders:
• Order ID: [order_id]
Company Code: [company_code]
Order Date: [order_initdate]
Completion Date: [order_compdate]
Notes: [status_notes]

---

6. When showing summary stats, you MUST format the response EXACTLY like this:

Ok [user_name], here is your order summary:
• Total Orders: [total_orders]
• Pending: [pending_count]
• Processing: [processing_count]
• Completed: [completed_count]
• Cancelled: [cancelled_count]
"""

# Initialize the agent, session service, artifact service, and runner ONCE
session_service = InMemorySessionService()
artifacts_service = InMemoryArtifactService()

vertexai.init(project=PROJECT_ID, location=LOCATION)

llm = Gemini(model="gemini-2.5-flash")

async def header_retriever(request: Request):
    """Get the ID token from the request headers"""
    id_token = request.headers.get('Authorization')
    return {"Authorization": id_token} if id_token else {}

async def process_message(message: str, history: list, session_id: str, user_id: str, id_token: str = None):
    async def get_auth_token():
        print("[DEBUG] get_auth_token called. id_token:", id_token)
        if id_token and id_token.startswith("Bearer "):
            return id_token[len("Bearer "):]
        return id_token if id_token else ""

    # Create session service per request (or use a shared one if you know it's safe)
    session_service = InMemorySessionService()

    toolbox = ToolboxToolset(
        server_url="https://toolbox-535807247199.us-central1.run.app",
        toolset_name="my-toolset",
        auth_token_getters={"google_signin": get_auth_token}
    )
    agent = Agent(
        name="finn",
        model=llm,
        instruction=prompt,
        tools=[toolbox]
    )
    runner = Runner(
        app_name="finn",
        agent=agent,
        session_service=session_service
    )

    # Ensure session exists
    session = session_service.sessions.get(session_id)
    if session is None:
        session = await session_service.create_session(
            state={}, app_name='finn', user_id=user_id, session_id=session_id
        )

    content = types.Content(role='user', parts=[types.Part(text=message)])

    # This is the async generator!
    async def event_stream():
        async for event in runner.run_async(session_id=session_id, user_id=user_id, new_message=content):
            for part in event.content.parts:
                if part.text is not None:
                    yield part.text

    return event_stream  # Return the async generator function itself

def get_current_user_id(session):
    """
    Helper function to get the current user ID from session
    """
    return session.get_state("user_id")
