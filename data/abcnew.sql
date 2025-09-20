--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: alloydbsuperuser
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO alloydbsuperuser;

--
-- Name: google_ml_integration; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS google_ml_integration WITH SCHEMA public;


--
-- Name: EXTENSION google_ml_integration; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION google_ml_integration IS 'Google extension for ML integration';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: alloydb_scann; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS alloydb_scann WITH SCHEMA public;


--
-- Name: EXTENSION alloydb_scann; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION alloydb_scann IS 'AlloyDB ScaNN Search';


--
-- Name: google_columnar_engine; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS google_columnar_engine WITH SCHEMA public;


--
-- Name: google_db_advisor; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS google_db_advisor WITH SCHEMA public;


--
-- Name: hypopg; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hypopg WITH SCHEMA public;


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

-- Create sequence for order_id
CREATE SEQUENCE public.custom_orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Create table
CREATE TABLE public.custom_orders (
    order_id integer NOT NULL DEFAULT nextval('public.custom_orders_order_id_seq'::regclass),
    company_code character varying(50) NOT NULL,
    order_status character varying(50) DEFAULT 'pending' NOT NULL,
    order_initdate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_compdate timestamp,
    status_notes text,
    CONSTRAINT custom_orders_pkey PRIMARY KEY (order_id)
);

-- Set owner (optional, as in your dump)
ALTER TABLE public.custom_orders OWNER TO postgres;
ALTER SEQUENCE public.custom_orders_order_id_seq OWNER TO postgres;
-- Insert sample data into custom_orders
INSERT INTO public.custom_orders 
(company_code, order_status, order_initdate, order_compdate, status_notes) 
VALUES
('COMP001', 'pending', '2025-01-02 10:15:00', NULL, 'Awaiting confirmation'),
('COMP002', 'processing', '2025-01-05 12:30:00', NULL, 'Payment received'),
('COMP003', 'completed', '2025-01-07 09:10:00', '2025-01-10 15:20:00', 'Delivered successfully'),
('COMP004', 'cancelled', '2025-01-08 14:00:00', '2025-01-08 16:00:00', 'Customer cancelled'),
('COMP005', 'pending', '2025-01-09 11:45:00', NULL, 'New order placed'),
('COMP006', 'processing', '2025-01-11 08:20:00', NULL, 'Packaging in progress'),
('COMP007', 'completed', '2025-01-12 13:30:00', '2025-01-15 09:00:00', 'Shipped and delivered'),
('COMP008', 'pending', '2025-01-13 17:45:00', NULL, 'Waiting for stock'),
('COMP009', 'cancelled', '2025-01-14 10:25:00', '2025-01-14 11:00:00', 'Out of stock'),
('COMP010', 'completed', '2025-01-15 09:00:00', '2025-01-17 14:30:00', 'Delivered to customer'),

('COMP011', 'pending', '2025-01-18 10:00:00', NULL, 'Awaiting approval'),
('COMP012', 'processing', '2025-01-19 12:10:00', NULL, 'In warehouse'),
('COMP013', 'completed', '2025-01-20 09:40:00', '2025-01-22 16:15:00', 'Delivery signed'),
('COMP014', 'cancelled', '2025-01-21 11:20:00', '2025-01-21 13:00:00', 'Payment failed'),
('COMP015', 'pending', '2025-01-22 15:30:00', NULL, 'Order created'),
('COMP016', 'processing', '2025-01-23 14:15:00', NULL, 'Quality check'),
('COMP017', 'completed', '2025-01-24 09:05:00', '2025-01-26 10:10:00', 'Delivered at doorstep'),
('COMP018', 'pending', '2025-01-25 10:55:00', NULL, 'Awaiting confirmation'),
('COMP019', 'completed', '2025-01-26 08:30:00', '2025-01-28 17:45:00', 'Received by customer'),
('COMP020', 'cancelled', '2025-01-27 14:25:00', '2025-01-27 15:30:00', 'Duplicate order'),

('COMP021', 'processing', '2025-02-01 09:15:00', NULL, 'Picked from warehouse'),
('COMP022', 'completed', '2025-02-02 11:00:00', '2025-02-04 13:20:00', 'Delivered'),
('COMP023', 'pending', '2025-02-03 15:30:00', NULL, 'Awaiting stock'),
('COMP024', 'processing', '2025-02-04 10:50:00', NULL, 'Preparing for shipment'),
('COMP025', 'completed', '2025-02-05 09:30:00', '2025-02-07 18:10:00', 'Signed by customer'),
('COMP026', 'cancelled', '2025-02-06 14:45:00', '2025-02-06 15:10:00', 'Cancelled by admin'),
('COMP027', 'completed', '2025-02-07 10:20:00', '2025-02-09 09:15:00', 'Delivered without issues'),
('COMP028', 'pending', '2025-02-08 11:40:00', NULL, 'Order received'),
('COMP029', 'processing', '2025-02-09 13:25:00', NULL, 'In sorting center'),
('COMP030', 'completed', '2025-02-10 12:15:00', '2025-02-12 14:50:00', 'Delivered'),

('COMP031', 'pending', '2025-02-13 09:30:00', NULL, 'Waiting approval'),
('COMP032', 'processing', '2025-02-14 11:25:00', NULL, 'Dispatched'),
('COMP033', 'cancelled', '2025-02-15 10:40:00', '2025-02-15 11:20:00', 'Cancelled by user'),
('COMP034', 'completed', '2025-02-16 09:00:00', '2025-02-18 16:40:00', 'Delivered'),
('COMP035', 'pending', '2025-02-17 13:50:00', NULL, 'Awaiting shipment'),
('COMP036', 'completed', '2025-02-18 15:05:00', '2025-02-20 10:20:00', 'Delivered successfully'),
('COMP037', 'processing', '2025-02-19 08:45:00', NULL, 'Packed and ready'),
('COMP038', 'pending', '2025-02-20 09:25:00', NULL, 'Awaiting payment'),
('COMP039', 'completed', '2025-02-21 11:35:00', '2025-02-23 12:30:00', 'Customer confirmed delivery'),
('COMP040', 'cancelled', '2025-02-22 10:10:00', '2025-02-22 10:45:00', 'Cancelled by system'),

('COMP041', 'completed', '2025-02-23 09:00:00', '2025-02-25 14:30:00', 'Delivered'),
('COMP042', 'pending', '2025-02-24 12:15:00', NULL, 'Awaiting dispatch'),
('COMP043', 'processing', '2025-02-25 10:20:00', NULL, 'At hub'),
('COMP044', 'completed', '2025-02-26 09:40:00', '2025-02-28 16:10:00', 'Delivered'),
('COMP045', 'cancelled', '2025-02-27 14:00:00', '2025-02-27 14:30:00', 'Cancelled by customer'),
('COMP046', 'processing', '2025-02-28 13:25:00', NULL, 'Shipment in progress'),
('COMP047', 'completed', '2025-03-01 08:15:00', '2025-03-03 09:20:00', 'Delivered successfully'),
('COMP048', 'pending', '2025-03-02 10:50:00', NULL, 'Awaiting processing'),
('COMP049', 'processing', '2025-03-03 11:35:00', NULL, 'In queue'),
('COMP050', 'completed', '2025-03-04 12:20:00', '2025-03-06 15:45:00', 'Delivered on time');


--
-- PostgreSQL database dump complete
--

