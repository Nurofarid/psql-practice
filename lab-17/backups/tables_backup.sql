--
-- PostgreSQL database dump
--

\restrict IWn6xie6RhDfR5PDePrZz5xXQX1ZEPJnc8jquasZ9TGRd0kdFki3kPhZqI5AMWy

-- Dumped from database version 18.6 (Homebrew)
-- Dumped by pg_dump version 18.6 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: nurofaridkukanbekova
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    first_name character varying(30),
    last_name character varying(30),
    email character varying(50),
    department character varying(20)
);


ALTER TABLE public.employees OWNER TO nurofaridkukanbekova;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: nurofaridkukanbekova
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO nurofaridkukanbekova;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nurofaridkukanbekova
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: nurofaridkukanbekova
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(50),
    price numeric(8,2)
);


ALTER TABLE public.products OWNER TO nurofaridkukanbekova;

--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: nurofaridkukanbekova
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.employees (id, first_name, last_name, email, department) FROM stdin;
1	Aibek	Sharshenov	aibek@co.kg	IT
2	Ainura	Toktomamatova	\N	Sales
3	Bakyt	Mamatov	bakyt@co.kg	IT
4	Meerim	Bekova	meerim@co.kg	HR
5	Tilek	Usubaliev	tilek@co.kg	\N
6	Gulzat	Sultanova	\N	\N
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.products (id, name, price) FROM stdin;
1	Laptop	1200.00
2	Phone	650.00
3	Headphones	80.00
10	Mouse	25.00
12	Monitor	300.00
\.


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nurofaridkukanbekova
--

SELECT pg_catalog.setval('public.employees_id_seq', 6, true);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: nurofaridkukanbekova
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: nurofaridkukanbekova
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict IWn6xie6RhDfR5PDePrZz5xXQX1ZEPJnc8jquasZ9TGRd0kdFki3kPhZqI5AMWy

