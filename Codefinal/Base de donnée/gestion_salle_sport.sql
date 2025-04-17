--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2024-12-02 00:43:03

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
-- TOC entry 4951 (class 1262 OID 16524)
-- Name: gestion_salle_sport; Type: DATABASE; Schema: -; Owner: a-watier
--

CREATE DATABASE gestion_salle_sport WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'French_France.1252';


ALTER DATABASE gestion_salle_sport OWNER TO "a-watier";

\connect gestion_salle_sport

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
-- TOC entry 871 (class 1247 OID 16669)
-- Name: type_abo; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.type_abo AS ENUM (
    'Mensuel',
    'Annuel',
    'Semestriel'
);


ALTER TYPE public.type_abo OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 16656)
-- Name: abonne; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abonne (
    id_abonne character(11) NOT NULL,
    date_souscription timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    id_abonnement character(11) NOT NULL,
    CONSTRAINT chk_id_abonne CHECK ((id_abonne ~~ 'Abo%'::text))
);


ALTER TABLE public.abonne OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16689)
-- Name: abonnement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abonnement (
    id_abonnement character(11) NOT NULL,
    type_abonnement public.type_abo NOT NULL,
    tarif_abonnement double precision NOT NULL,
    debut_abonnement timestamp without time zone NOT NULL,
    fin_abonnement timestamp without time zone NOT NULL,
    CONSTRAINT chk_debut_abonnement CHECK ((debut_abonnement <= now())),
    CONSTRAINT chk_fin_abonnement CHECK ((fin_abonnement > debut_abonnement)),
    CONSTRAINT chk_id_abonnement CHECK ((id_abonnement ~~ 'Abn%'::text)),
    CONSTRAINT chk_tarif_abonnement CHECK ((tarif_abonnement >= (0)::double precision))
);


ALTER TABLE public.abonnement OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16535)
-- Name: creneau; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.creneau (
    id_creneau character(11) NOT NULL,
    date_creneau date NOT NULL,
    heure_debut time without time zone NOT NULL,
    heure_fin time without time zone NOT NULL,
    id_salle_sport character(11) NOT NULL,
    id_utilisateur character(11) NOT NULL,
    used boolean DEFAULT false,
    tarif_creneau double precision DEFAULT 0,
    CONSTRAINT heure_check CHECK ((heure_debut < heure_fin))
);


ALTER TABLE public.creneau OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16754)
-- Name: equipement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipement (
    id_equipement character varying(11) NOT NULL,
    nom_equipement character varying(50),
    CONSTRAINT equipement_id_equipement_check CHECK (((id_equipement)::text ~~ '%Eqp'::text))
);


ALTER TABLE public.equipement OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16712)
-- Name: instructeur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructeur (
    id_instructeur character varying(11) NOT NULL,
    nom character varying(50) NOT NULL,
    prenom character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    type_entrainement character varying(50) NOT NULL,
    CONSTRAINT instructeur_id_instructeur_check CHECK (((id_instructeur)::text ~~ 'Ins%'::text))
);


ALTER TABLE public.instructeur OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16760)
-- Name: reserver_equipement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reserver_equipement (
    id_abonne character varying(11) NOT NULL,
    id_equipement character varying(11) NOT NULL,
    date_reservation date NOT NULL,
    heure_debut time without time zone NOT NULL,
    heure_fin time without time zone NOT NULL
);


ALTER TABLE public.reserver_equipement OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16720)
-- Name: salle_specifique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salle_specifique (
    id_salle_specifique character varying(11) NOT NULL,
    nom_salle character varying(50) NOT NULL,
    place_disponible integer,
    id_salle_sport character varying(11) NOT NULL,
    CONSTRAINT salle_specifique_id_salle_specifique_check CHECK (((id_salle_specifique)::text ~~ 'Sps%'::text)),
    CONSTRAINT salle_specifique_place_disponible_check CHECK (((place_disponible >= 0) AND (place_disponible <= 100)))
);


ALTER TABLE public.salle_specifique OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16530)
-- Name: salle_sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salle_sport (
    id_salle_sport character(11) NOT NULL,
    nom_salle character varying(50) NOT NULL,
    ville character varying(50),
    rue character varying(100),
    numero_rue character varying(50)
);


ALTER TABLE public.salle_sport OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16553)
-- Name: scanner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scanner (
    id_scanner character(11) NOT NULL,
    id_salle_sport character(11) NOT NULL
);


ALTER TABLE public.scanner OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16732)
-- Name: seance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seance (
    id_seance character varying(11) NOT NULL,
    type_seance character varying(50) NOT NULL,
    date_seance date NOT NULL,
    heure_debut time without time zone NOT NULL,
    heure_fin time without time zone NOT NULL,
    id_instructeur character varying(11),
    id_salle_specifique character varying(11),
    CONSTRAINT seance_id_seance_check CHECK (((id_seance)::text ~~ 'Sea%'::text))
);


ALTER TABLE public.seance OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16525)
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur (
    id_utilisateur character(11) NOT NULL,
    nom character varying(30) NOT NULL,
    prenom character varying(30) NOT NULL,
    email character varying(255) NOT NULL,
    login character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    CONSTRAINT chk_email CHECK (((email)::text ~~ '%@%'::text)),
    CONSTRAINT chk_id_utilisateur CHECK (((id_utilisateur ~~ 'Uti%'::text) OR (id_utilisateur ~~ 'Abo%'::text)))
);


ALTER TABLE public.utilisateur OWNER TO postgres;

--
-- TOC entry 4939 (class 0 OID 16656)
-- Dependencies: 221
-- Data for Name: abonne; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abonne (id_abonne, date_souscription, id_abonnement) FROM stdin;
Abo00000001	2024-12-01 00:00:00	Abn00000001
\.


--
-- TOC entry 4940 (class 0 OID 16689)
-- Dependencies: 222
-- Data for Name: abonnement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abonnement (id_abonnement, type_abonnement, tarif_abonnement, debut_abonnement, fin_abonnement) FROM stdin;
Abn00000001	Mensuel	12.5	2024-12-01 14:30:00	2025-01-01 14:30:00
\.


--
-- TOC entry 4937 (class 0 OID 16535)
-- Dependencies: 219
-- Data for Name: creneau; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.creneau (id_creneau, date_creneau, heure_debut, heure_fin, id_salle_sport, id_utilisateur, used, tarif_creneau) FROM stdin;
Cre00000002	2024-10-28	03:00:00	04:00:00	Sal00000002	Uti00000002	f	0
Cre00000001	2024-10-28	04:00:00	07:00:00	Sal00000001	Uti00000001	t	0
\.


--
-- TOC entry 4944 (class 0 OID 16754)
-- Dependencies: 226
-- Data for Name: equipement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipement (id_equipement, nom_equipement) FROM stdin;
\.


--
-- TOC entry 4941 (class 0 OID 16712)
-- Dependencies: 223
-- Data for Name: instructeur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructeur (id_instructeur, nom, prenom, email, type_entrainement) FROM stdin;
\.


--
-- TOC entry 4945 (class 0 OID 16760)
-- Dependencies: 227
-- Data for Name: reserver_equipement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reserver_equipement (id_abonne, id_equipement, date_reservation, heure_debut, heure_fin) FROM stdin;
\.


--
-- TOC entry 4942 (class 0 OID 16720)
-- Dependencies: 224
-- Data for Name: salle_specifique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salle_specifique (id_salle_specifique, nom_salle, place_disponible, id_salle_sport) FROM stdin;
\.


--
-- TOC entry 4936 (class 0 OID 16530)
-- Dependencies: 218
-- Data for Name: salle_sport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salle_sport (id_salle_sport, nom_salle, ville, rue, numero_rue) FROM stdin;
Sal00000001	FitCenter de la Paix	Paris	Rue de la Paix	12
Sal00000002	FitCenter Hugo	Lyon	Rue Victor Hugo	23
Sal00000003	FitCenter du Prado	Marseille	Avenue du Prado	45
\.


--
-- TOC entry 4938 (class 0 OID 16553)
-- Dependencies: 220
-- Data for Name: scanner; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scanner (id_scanner, id_salle_sport) FROM stdin;
Sca00000001	Sal00000001
Sca00000002	Sal00000001
Sca00000003	Sal00000002
Sca00000004	Sal00000003
\.


--
-- TOC entry 4943 (class 0 OID 16732)
-- Dependencies: 225
-- Data for Name: seance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seance (id_seance, type_seance, date_seance, heure_debut, heure_fin, id_instructeur, id_salle_specifique) FROM stdin;
\.


--
-- TOC entry 4935 (class 0 OID 16525)
-- Dependencies: 217
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur (id_utilisateur, nom, prenom, email, login, password) FROM stdin;
Uti00000001	Dupont	Pierre	pierre.dupont@email.com	pdupont	Pwd123!
Uti00000002	Martin	Sophie	sophie.martin@email.com	smartin	Pass456?
Uti00000003	Lefevre	Antoine	antoine.lefevre@email.com	alefevre	AntoineL9
Uti00000004	Bernard	Claire	claire.bernard@email.com	cbernard	ClaireB!5
Uti00000005	Moreau	Julien	julien.moreau@email.com	jmoreau	JMpass12
Abo00000001	Jean	Charle	jean.charle@email.com	JCharle	pass123*
\.


--
-- TOC entry 4763 (class 2606 OID 16557)
-- Name: scanner Scanner_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scanner
    ADD CONSTRAINT "Scanner_pkey" PRIMARY KEY (id_scanner);


--
-- TOC entry 4765 (class 2606 OID 16662)
-- Name: abonne abonne_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abonne
    ADD CONSTRAINT abonne_pkey PRIMARY KEY (id_abonne);


--
-- TOC entry 4767 (class 2606 OID 16697)
-- Name: abonnement abonnement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abonnement
    ADD CONSTRAINT abonnement_pkey PRIMARY KEY (id_abonnement);


--
-- TOC entry 4761 (class 2606 OID 16540)
-- Name: creneau creneau_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creneau
    ADD CONSTRAINT creneau_pkey PRIMARY KEY (id_creneau);


--
-- TOC entry 4777 (class 2606 OID 16759)
-- Name: equipement equipement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipement
    ADD CONSTRAINT equipement_pkey PRIMARY KEY (id_equipement);


--
-- TOC entry 4769 (class 2606 OID 16719)
-- Name: instructeur instructeur_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructeur
    ADD CONSTRAINT instructeur_email_key UNIQUE (email);


--
-- TOC entry 4771 (class 2606 OID 16717)
-- Name: instructeur instructeur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructeur
    ADD CONSTRAINT instructeur_pkey PRIMARY KEY (id_instructeur);


--
-- TOC entry 4779 (class 2606 OID 16764)
-- Name: reserver_equipement reserver_equipement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserver_equipement
    ADD CONSTRAINT reserver_equipement_pkey PRIMARY KEY (id_abonne, id_equipement);


--
-- TOC entry 4773 (class 2606 OID 16726)
-- Name: salle_specifique salle_specifique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salle_specifique
    ADD CONSTRAINT salle_specifique_pkey PRIMARY KEY (id_salle_specifique);


--
-- TOC entry 4759 (class 2606 OID 16534)
-- Name: salle_sport salle_sport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salle_sport
    ADD CONSTRAINT salle_sport_pkey PRIMARY KEY (id_salle_sport);


--
-- TOC entry 4775 (class 2606 OID 16737)
-- Name: seance seance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seance
    ADD CONSTRAINT seance_pkey PRIMARY KEY (id_seance);


--
-- TOC entry 4755 (class 2606 OID 16654)
-- Name: utilisateur unique_user_login; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT unique_user_login UNIQUE (login);


--
-- TOC entry 4757 (class 2606 OID 16529)
-- Name: utilisateur utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (id_utilisateur);


--
-- TOC entry 4783 (class 2606 OID 16698)
-- Name: abonne chk_id_abonnement; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abonne
    ADD CONSTRAINT chk_id_abonnement FOREIGN KEY (id_abonnement) REFERENCES public.abonnement(id_abonnement);


--
-- TOC entry 4784 (class 2606 OID 16703)
-- Name: abonne fk_abonne_utilisateur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abonne
    ADD CONSTRAINT fk_abonne_utilisateur FOREIGN KEY (id_abonne) REFERENCES public.utilisateur(id_utilisateur);


--
-- TOC entry 4785 (class 2606 OID 16727)
-- Name: salle_specifique fk_salle_specifique_salle_sport; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salle_specifique
    ADD CONSTRAINT fk_salle_specifique_salle_sport FOREIGN KEY (id_salle_sport) REFERENCES public.salle_sport(id_salle_sport);


--
-- TOC entry 4786 (class 2606 OID 16738)
-- Name: seance fk_seance_instructeur; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seance
    ADD CONSTRAINT fk_seance_instructeur FOREIGN KEY (id_instructeur) REFERENCES public.instructeur(id_instructeur);


--
-- TOC entry 4787 (class 2606 OID 16743)
-- Name: seance fk_seance_salle; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seance
    ADD CONSTRAINT fk_seance_salle FOREIGN KEY (id_salle_specifique) REFERENCES public.salle_specifique(id_salle_specifique);


--
-- TOC entry 4780 (class 2606 OID 16541)
-- Name: creneau id_salle_sport_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creneau
    ADD CONSTRAINT id_salle_sport_fk FOREIGN KEY (id_salle_sport) REFERENCES public.salle_sport(id_salle_sport);


--
-- TOC entry 4782 (class 2606 OID 16558)
-- Name: scanner id_salle_sport_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scanner
    ADD CONSTRAINT id_salle_sport_fk FOREIGN KEY (id_salle_sport) REFERENCES public.salle_sport(id_salle_sport);


--
-- TOC entry 4781 (class 2606 OID 16546)
-- Name: creneau id_utilisateur_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creneau
    ADD CONSTRAINT id_utilisateur_fk FOREIGN KEY (id_utilisateur) REFERENCES public.utilisateur(id_utilisateur);


--
-- TOC entry 4788 (class 2606 OID 16765)
-- Name: reserver_equipement reserver_equipement_id_abonne_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserver_equipement
    ADD CONSTRAINT reserver_equipement_id_abonne_fkey FOREIGN KEY (id_abonne) REFERENCES public.abonne(id_abonne);


--
-- TOC entry 4789 (class 2606 OID 16770)
-- Name: reserver_equipement reserver_equipement_id_equipement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reserver_equipement
    ADD CONSTRAINT reserver_equipement_id_equipement_fkey FOREIGN KEY (id_equipement) REFERENCES public.equipement(id_equipement);


--
-- TOC entry 4952 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE abonne; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.abonne TO etu;


--
-- TOC entry 4953 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE abonnement; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.abonnement TO etu;


--
-- TOC entry 4954 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE equipement; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.equipement TO etu;


--
-- TOC entry 4955 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE instructeur; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.instructeur TO etu;


--
-- TOC entry 4956 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE reserver_equipement; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.reserver_equipement TO etu;


--
-- TOC entry 4957 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE salle_specifique; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.salle_specifique TO etu;


--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE scanner; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.scanner TO etu;


--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE seance; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.seance TO etu;


--
-- TOC entry 2086 (class 826 OID 16551)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO etu;


-- Completed on 2024-12-02 00:43:04

--
-- PostgreSQL database dump complete
--

