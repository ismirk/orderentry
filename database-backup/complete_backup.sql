--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 15.13 (Debian 15.13-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS orderdb;
--
-- Name: orderdb; Type: DATABASE; Schema: -; Owner: orderuser
--

CREATE DATABASE orderdb WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE orderdb OWNER TO orderuser;

\connect orderdb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: orderuser
--

CREATE TABLE public.customer (
    customer_code character varying(20) NOT NULL,
    customer_name character varying(50)
);


ALTER TABLE public.customer OWNER TO orderuser;

--
-- Name: order; Type: TABLE; Schema: public; Owner: orderuser
--

CREATE TABLE public."order" (
    order_id integer NOT NULL,
    order_date date,
    description character varying(50),
    customer_name character varying(20),
    total numeric,
    customer_code character varying(20)
);


ALTER TABLE public."order" OWNER TO orderuser;

--
-- Name: order_details; Type: TABLE; Schema: public; Owner: orderuser
--

CREATE TABLE public.order_details (
    order_id integer NOT NULL,
    order_no integer NOT NULL,
    product_item character varying(50),
    unit_price numeric,
    qty numeric,
    subtotal numeric,
    product_code character varying(20)
);


ALTER TABLE public.order_details OWNER TO orderuser;

--
-- Name: order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: orderuser
--

CREATE SEQUENCE public.order_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_order_id_seq OWNER TO orderuser;

--
-- Name: order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: orderuser
--

ALTER SEQUENCE public.order_order_id_seq OWNED BY public."order".order_id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: orderuser
--

CREATE TABLE public.product (
    product_code character varying(20) NOT NULL,
    product_name character varying(50),
    product_price numeric(38,16)
);


ALTER TABLE public.product OWNER TO orderuser;

--
-- Name: order order_id; Type: DEFAULT; Schema: public; Owner: orderuser
--

ALTER TABLE ONLY public."order" ALTER COLUMN order_id SET DEFAULT nextval('public.order_order_id_seq'::regclass);


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: orderuser
--

COPY public.customer (customer_code, customer_name) FROM stdin;
IK	Ismir Kamili
JD	John Doe
BD	Budi Darsono
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: orderuser
--

COPY public."order" (order_id, order_date, description, customer_name, total, customer_code) FROM stdin;
\.


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: orderuser
--

COPY public.order_details (order_id, order_no, product_item, unit_price, qty, subtotal, product_code) FROM stdin;
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: orderuser
--

COPY public.product (product_code, product_name, product_price) FROM stdin;
HB1	Halo Balita Seri 1	50000.0000000000000000
HB2	Halo Balita Seri 2	50000.0000000000000000
KAJ500	Kurma Ajwa 500 gr	200000.0000000000000000
CKL01	Chocolate Package 1	150000.0000000000000000
\.


--
-- Name: order_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: orderuser
--

SELECT pg_catalog.setval('public.order_order_id_seq', 1, false);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: orderuser
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_code);


--
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: orderuser
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (order_id, order_no);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: orderuser
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (order_id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: orderuser
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_code);


--
-- Name: order_details order_details_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: orderuser
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_order_id_fkey FOREIGN KEY (order_id) REFERENCES public."order"(order_id);


--
-- PostgreSQL database dump complete
--

