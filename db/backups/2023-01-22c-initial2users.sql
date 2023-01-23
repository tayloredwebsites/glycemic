--
-- PostgreSQL database dump
--

-- Dumped from database version 12.13 (Ubuntu 12.13-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.13 (Ubuntu 12.13-0ubuntu0.20.04.1)

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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: dave
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO dave;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: dave
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO dave;

--
-- Name: users; Type: TABLE; Schema: public; Owner: dave
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    username character varying,
    full_name character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO dave;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: dave
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO dave;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dave
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: dave
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: dave
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2023-01-13 18:29:06.952736	2023-01-13 18:29:06.952736
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: dave
--

COPY public.schema_migrations (version) FROM stdin;
20230113180601
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: dave
--

COPY public.users (id, email, username, full_name, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, confirmation_token, confirmed_at, confirmation_sent_at, unconfirmed_email, failed_attempts, unlock_token, locked_at, created_at, updated_at) FROM stdin;
1	davida.taylor@me.com	\N	\N	$2a$12$VZPVqu5BilL7yQBaumX/uuxzOO83ENYtW8OBhlRby/a5ZdT2gAMqi	\N	\N	\N	xvi_T1K3xMFk5TvKzMx2	2023-01-17 21:46:05.991981	2023-01-17 21:32:11.388713	\N	0	\N	\N	2023-01-13 21:37:40.963029	2023-01-17 21:46:05.992443
2	tayloredwebsites@me.com	\N	\N	$2a$12$JZqf2MD6SfK/nEHO/an4jOYQNCexYHKCZUaNw8C6qhuQm1NjZ4BuK	\N	\N	\N	NJbzSWKp-bbmDrMssMbg	2023-01-22 21:28:00.82307	2023-01-22 21:27:01.112468	\N	0	\N	\N	2023-01-22 21:27:01.112147	2023-01-22 21:28:00.823388
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dave
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: dave
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: dave
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: dave
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: dave
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: dave
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: dave
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: dave
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- PostgreSQL database dump complete
--

