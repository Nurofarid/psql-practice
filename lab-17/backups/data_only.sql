--
-- PostgreSQL database dump
--

\restrict 3v4N3TMbmC5kAq3LnKp2lTf5zkoOOqQew6lAjVxzdXRDe3d5QdRO5I9uZ98bRf7

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

--
-- Data for Name: customer_feedback; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.customer_feedback (id, comment) FROM stdin;
1	Fast delivery, good price
2	The box said "fragile", but it was fine
\.


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
-- Data for Name: feedback_copy; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.feedback_copy (id, comment) FROM stdin;
1	Fast delivery, good price
2	The box said "fragile", but it was fine
\.


--
-- Data for Name: log_table; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.log_table (id, message) FROM stdin;
1	debug 1
2	debug 2
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.orders (order_id, customer, order_date, total) FROM stdin;
1	Aida	2026-10-01	250.00
2	Timur	2026-10-15	45.50
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
-- Data for Name: products_copy; Type: TABLE DATA; Schema: public; Owner: nurofaridkukanbekova
--

COPY public.products_copy (id, name, price) FROM stdin;
1	Laptop	1200.00
2	Phone	650.00
3	Headphones	80.00
\.


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nurofaridkukanbekova
--

SELECT pg_catalog.setval('public.employees_id_seq', 6, true);


--
-- Name: log_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nurofaridkukanbekova
--

SELECT pg_catalog.setval('public.log_table_id_seq', 2, true);


--
-- PostgreSQL database dump complete
--

\unrestrict 3v4N3TMbmC5kAq3LnKp2lTf5zkoOOqQew6lAjVxzdXRDe3d5QdRO5I9uZ98bRf7

