--
-- PostgreSQL database dump
--

\restrict d0Fe7jqrVAwN3ZW2dDa8PsyqLWlgxypXQs7yovHd8cfnw6fa3AFVKUMNVlY9sQ4

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

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

ALTER TABLE IF EXISTS ONLY public.winners DROP CONSTRAINT IF EXISTS winners_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.winners DROP CONSTRAINT IF EXISTS winners_team_id_fkey;
ALTER TABLE IF EXISTS ONLY public.winners DROP CONSTRAINT IF EXISTS winners_hackathon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.teams DROP CONSTRAINT IF EXISTS teams_leader_id_fkey;
ALTER TABLE IF EXISTS ONLY public.teams DROP CONSTRAINT IF EXISTS teams_hackathon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.team_members DROP CONSTRAINT IF EXISTS team_members_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.team_members DROP CONSTRAINT IF EXISTS team_members_team_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tasks DROP CONSTRAINT IF EXISTS tasks_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tasks DROP CONSTRAINT IF EXISTS tasks_hackathon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_hackathon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.student_submissions DROP CONSTRAINT IF EXISTS student_submissions_hackathon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.registrations DROP CONSTRAINT IF EXISTS registrations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.registrations DROP CONSTRAINT IF EXISTS registrations_hackathon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leaderboard DROP CONSTRAINT IF EXISTS leaderboard_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.winners DROP CONSTRAINT IF EXISTS winners_pkey;
ALTER TABLE IF EXISTS ONLY public.winners DROP CONSTRAINT IF EXISTS winners_hackathon_id_user_id_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.teams DROP CONSTRAINT IF EXISTS teams_pkey;
ALTER TABLE IF EXISTS ONLY public.team_members DROP CONSTRAINT IF EXISTS team_members_team_id_email_key;
ALTER TABLE IF EXISTS ONLY public.team_members DROP CONSTRAINT IF EXISTS team_members_pkey;
ALTER TABLE IF EXISTS ONLY public.tasks DROP CONSTRAINT IF EXISTS tasks_pkey;
ALTER TABLE IF EXISTS ONLY public.submissions DROP CONSTRAINT IF EXISTS submissions_pkey;
ALTER TABLE IF EXISTS ONLY public.student_submissions DROP CONSTRAINT IF EXISTS student_submissions_pkey;
ALTER TABLE IF EXISTS ONLY public.registrations DROP CONSTRAINT IF EXISTS registrations_pkey;
ALTER TABLE IF EXISTS ONLY public.registrations DROP CONSTRAINT IF EXISTS registrations_hackathon_id_user_id_key;
ALTER TABLE IF EXISTS ONLY public.leaderboard DROP CONSTRAINT IF EXISTS leaderboard_pkey;
ALTER TABLE IF EXISTS ONLY public.hackathons DROP CONSTRAINT IF EXISTS hackathons_source_url_key;
ALTER TABLE IF EXISTS ONLY public.hackathons DROP CONSTRAINT IF EXISTS hackathons_pkey;
ALTER TABLE IF EXISTS public.winners ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.teams ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.team_members ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tasks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.submissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.student_submissions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.registrations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.leaderboard ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.hackathons ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.winners_id_seq;
DROP TABLE IF EXISTS public.winners;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.teams_id_seq;
DROP TABLE IF EXISTS public.teams;
DROP SEQUENCE IF EXISTS public.team_members_id_seq;
DROP TABLE IF EXISTS public.team_members;
DROP SEQUENCE IF EXISTS public.tasks_id_seq;
DROP TABLE IF EXISTS public.tasks;
DROP SEQUENCE IF EXISTS public.submissions_id_seq;
DROP TABLE IF EXISTS public.submissions;
DROP SEQUENCE IF EXISTS public.student_submissions_id_seq;
DROP TABLE IF EXISTS public.student_submissions;
DROP SEQUENCE IF EXISTS public.registrations_id_seq;
DROP TABLE IF EXISTS public.registrations;
DROP SEQUENCE IF EXISTS public.leaderboard_id_seq;
DROP TABLE IF EXISTS public.leaderboard;
DROP SEQUENCE IF EXISTS public.hackathons_id_seq;
DROP TABLE IF EXISTS public.hackathons;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hackathons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hackathons (
    id integer NOT NULL,
    title text NOT NULL,
    source_url text NOT NULL,
    deadline timestamp without time zone,
    raw_data jsonb,
    dominant_hex character varying(7),
    status character varying(50) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    event_mode character varying(50) DEFAULT 'online'::character varying,
    sample_url text,
    description text,
    registration_deadline timestamp without time zone,
    event_date timestamp without time zone,
    prize_pool text,
    phases jsonb DEFAULT '[]'::jsonb,
    current_phase character varying(100) DEFAULT 'Registration'::character varying
);


--
-- Name: hackathons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hackathons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hackathons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hackathons_id_seq OWNED BY public.hackathons.id;


--
-- Name: leaderboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leaderboard (
    id integer NOT NULL,
    user_id integer,
    score integer DEFAULT 0,
    university character varying(255),
    department character varying(255),
    class_section character varying(255),
    trend character varying(50) DEFAULT 'same'::character varying,
    win_streak integer DEFAULT 0
);


--
-- Name: leaderboard_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leaderboard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leaderboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leaderboard_id_seq OWNED BY public.leaderboard.id;


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registrations (
    id integer NOT NULL,
    hackathon_id integer,
    user_id integer,
    status character varying(50) DEFAULT 'registered'::character varying,
    registered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registrations_id_seq OWNED BY public.registrations.id;


--
-- Name: student_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_submissions (
    id integer NOT NULL,
    student_id uuid NOT NULL,
    hackathon_id integer,
    proof_url text NOT NULL,
    verification_status character varying(50) DEFAULT 'pending'::character varying,
    ai_confidence double precision,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: student_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_submissions_id_seq OWNED BY public.student_submissions.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    hackathon_id integer,
    user_id integer,
    proof_url text,
    ai_status character varying(50) DEFAULT 'pending'::character varying,
    ai_feedback text,
    ai_confidence double precision DEFAULT 0.0,
    submitted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    hackathon_id integer,
    user_id integer,
    title character varying(255) NOT NULL,
    description text,
    due_date timestamp without time zone,
    status character varying(50) DEFAULT 'todo'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id integer NOT NULL,
    team_id integer,
    user_id integer,
    email character varying(255) NOT NULL,
    register_number character varying(100),
    invite_status character varying(50) DEFAULT 'pending'::character varying,
    proof_url text,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    hackathon_id integer,
    leader_id integer,
    status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'student'::character varying,
    avatar_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    password_hash character varying(255),
    wins integer DEFAULT 0,
    skills text[] DEFAULT '{}'::text[],
    university character varying(255),
    department character varying(255),
    win_count integer DEFAULT 0
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: winners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.winners (
    id integer NOT NULL,
    hackathon_id integer,
    user_id integer,
    team_id integer,
    won_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: winners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.winners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: winners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.winners_id_seq OWNED BY public.winners.id;


--
-- Name: hackathons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hackathons ALTER COLUMN id SET DEFAULT nextval('public.hackathons_id_seq'::regclass);


--
-- Name: leaderboard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaderboard ALTER COLUMN id SET DEFAULT nextval('public.leaderboard_id_seq'::regclass);


--
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations ALTER COLUMN id SET DEFAULT nextval('public.registrations_id_seq'::regclass);


--
-- Name: student_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_submissions ALTER COLUMN id SET DEFAULT nextval('public.student_submissions_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: winners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners ALTER COLUMN id SET DEFAULT nextval('public.winners_id_seq'::regclass);


--
-- Data for Name: hackathons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hackathons (id, title, source_url, deadline, raw_data, dominant_hex, status, created_at, event_mode, sample_url, description, registration_deadline, event_date, prize_pool, phases, current_phase) FROM stdin;
32	India AI Impact Festival 2026	https://indiaaiimpactfest.ai-for-all.in/	\N	\N	\N	active	2026-08-01 21:19:50.889699	online	https://indiaaiimpactfest.ai-for-all.in/images/hero/DSC_9700.webp	Celebrating transformative AI solutions that empower every Indian, ensuring technology drives progress that is accessible and equitable for all. The India AI Impact Festival 2026 invites participation under four categories: AI Impact Creators (for students), AI Impact Shapers (for educators), AI Impact Nurturers (for academic institutions), and AI Impact Catalysts (for start-ups). Submission deadline has been extended to July 26, 2026.	\N	\N	\N	[]	Registration
39	Sustainability Innovation Hackathon 2026	https://events-ihcfsi.org/	\N	\N	\N	active	2026-08-01 21:29:01.141131	online	https://events-ihcfsi.org/asset/objectives_visual.png	The Sustainable Innovation Hackathon 2026 is a multi-phase competition designed to bring creative and innovative ideas from students and early-stage innovators to build impactful sustainability solutions. The hackathon focuses on real-world sustainability challenges in various themes such as natural resources, agriculture, food, circular economy, clean energy, rural development, built environment, healthcare, water management, solid waste, transportation, and more.	\N	\N	upto ₹5 Lakh (Total prize pool)	[]	Registration
45	Aerothon 2026 - HAL x IITI	https://unstop.com/hackathons/aerothon-2026-hal-x-iiti-iit-indore-1709519	\N	\N	\N	active	2026-08-01 21:36:06.99544	online	https://d8it4huxumps7.cloudfront.net/uploads/images/opportunity/banner/6a45ed60f28b2_aerothon-2026-hal-x-iiti.png?d=720x600	Aerothon 2026 is a national-level aerospace hackathon organized by Hindustan Aeronautics Limited (HAL) in collaboration with Indian Institute of Technology (IIT) Indore, bringing together innovators, engineers, programmers, and researchers to tackle real-world challenges in aerospace engineering using data-driven approaches. Teams will work on cutting-edge problem statements inspired by modern aerospace engineering challenges.	\N	\N	up to ₹2,10,000	[]	Registration
61	Snowflake CoCo CLI Hackathon 2026	https://hack2skill.com/event/cococlihack/?utm_source=hack2skill&utm_medium=homepage	\N	\N	\N	active	2026-08-01 21:52:00.838838	online	https://h2svision.github.io/publicAssets/cortex/benefits/snowflakeLogo.svg	The Snowflake CoCo CLI Hackathon is a structured, execution-driven program designed for developers and data professionals to build AI-native applications on Snowflake's AI Data Cloud. The initiative focuses on applying AI to real-world data challenges, building end-to-end intelligent workflows, moving from concept → working prototype → final solution, and validating deployable systems.	2026-08-02 00:00:00	2026-09-04 13:00:00	$10,000	[]	Registration
67	AI Builders Hackathon	https://ai-builders-hackathon-2026.devpost.com/	\N	\N	\N	active	2026-08-01 21:59:40.772802	online	https://s3.amazonaws.com/challengepost/sponsors/logos/000/049/296/datas/large.png	Join the AI Builders Hackathon to build and submit AI-powered solutions that address real-world needs. Participants include students, developers, designers, startup founders, and AI enthusiasts.	\N	\N	$33,900 in cash and prizes	[]	Registration
72	The Next GD.Naidu Challenge	https://events-dailythanthi.com/gdn/registration/	\N	\N	\N	active	2026-08-01 22:08:01.529	online	https://events-dailythanthi.com/gdn/wp-content/uploads/2026/06/daily-thanthi-logo.png	Submit Your Project for the GDN Project Showcase and stand a chance to win exciting cash prizes worth up to ₹10 Lakhs!	\N	\N	₹10 Lakhs	[]	Registration
78	ScriptedBy{Her} 2026	https://www.hackerearth.com/community/challenges/hackathon/scriptedbyher-2026/	\N	\N	\N	active	2026-08-01 22:17:01.183054	online	https://media.hackerearth.com/media/hackathon/scriptedbyher-2026/images/9a44e9fc62-Copy_of_Banner_Final_Final_5_1.png	The hackathon is open to final-year female students graduating in 2027 across engineering colleges in India. The theme of the event is 'Building for Bharat with the Power of Agentic AI.' Participants must align their solutions with this theme and ensure that their projects are original and not submitted to any prior hackathons or competitions.	\N	2026-06-19 00:00:00	₹2.25 Lakhs in cash prizes	[]	Registration
85	Hackathon from forms.office.com	https://forms.office.com/r/HXpZDC7BAu	\N	\N	\N	active	2026-08-01 22:27:23.467418	online	\N	 Loading…...	2026-08-15 23:59:59	2026-08-20 09:00:00	\N	[]	Registration
18	BIG IDEA TECH DESIGN	https://vguard.in/bigideatech/index#timeline	\N	\N	\N	active	2026-08-01 21:02:50.921553	online	https://vguard.in/bigideatech/ui/client/images/logos/vguard-big-idea-2.png	The V-Guard Big Idea Tech Design Competition invites students to design and innovate solutions for real-world problems in various product categories. The competition aims to inspire innovation and connect India's brightest minds with industry leaders.	2026-08-06 14:00:00	2026-09-24 14:00:00	₹1.5 Lakh	[]	Registration
33	Innovation Challenge for Drone Application & Research (NIDAR)	https://www.nidar.org.in/	\N	\N	\N	active	2026-08-01 21:20:35.952642	online	https://www.nidar.org.in/AiAssets/rescue-swarm.png	NIDAR is India's largest drone innovation challenge, hosted by DFI in collaboration with MEITY and Swayaan. It motivates students and researchers to build collaborative autonomous drones for solving real world problems in disaster management and precision agriculture. The event features the opportunity to interact with experts from C-DAC, practical insights and guidance to support the development of solutions, and access industry mentorship.	\N	\N	₹65+ Lakhs	[]	Registration
40	Into the Void 2.0	https://void.exploitx.org/	\N	\N	\N	active	2026-08-01 21:29:25.614665	online	\N	A 24-hour cybersecurity challenge spanning across 10 different domains, held in an online format with offline finals at Chennai Institute of Technology, Chennai.	\N	\N	₹1,33,945+	[]	Registration
46	Tally CodeBrewers	https://internshala.com/tally-codebrewers	\N	\N	\N	active	2026-08-01 21:36:55.384438	online	https://internshala.com//static/images/footer/google_play_store.png	The Tally CodeBrewers hackathon is an online competition where participants can register individually or form a team of up to three members. The challenge consists of two stages: an online assessment and the 48-hour Hackathon event.	\N	\N	The Wizard of System Programming and The Commander of Full Stack	[]	Registration
51	ReFlow 2026	https://internshala.com/competitions/reflow-2026/	\N	\N	\N	active	2026-08-01 21:42:37.403538	Hybrid	https://internshala-competitions.s3.ap-south-1.amazonaws.com/competitions/wp-content/uploads/2026/04/13050601/header_logo.png	ReFlow 2026 is a specialized national innovation hackathon designed to catalyze creative, scalable, and empathetic solutions for menstrual health, hygiene, and wellness ecosystem management. It challenges biomedical engineers, software developers, UI/UX designers, and public health innovators to design products that break cultural stigmas, optimize structural supply chains, and build inclusive consumer tech solutions.	\N	\N	Industry Incubation & Mentorship, Investor Connections, Verified Certification	[]	Registration
63	KPIT Sparkle	https://sparkle.kpit.com/#/auth/web-page	\N	\N	\N	active	2026-08-01 21:55:53.056696	online	https://sparkle.kpit.com/assets/web-images/kpit-sparkle-idea-g.png	Compete with the brightest minds in engineering innovation and showcase your groundbreaking ideas. Secure substantial cash prizes for creating solutions that address real-world challenges.	\N	\N	1.7 Crore	[]	Registration
68	Unknown Title	https://volthacks.devpost.com/	\N	\N	\N	active	2026-08-01 22:01:16.761078	online	\N		\N	\N	\N	[]	Registration
86	OneAquaHealth IEEE Global Hackathon	https://oneaquahealth-ieee-hackathon.devpost.com/	\N	\N	\N	active	2026-08-01 22:29:11.364415	online	https://s3.amazonaws.com/challengepost/sponsors/logos/000/048/637/highres/EU_logo.png	The OneAquaHealth IEEE Global Hackathon focuses on improving the sustainability and health of urban freshwater ecosystems by combining technology, citizen science, and the One Health approach. The challenge invites participants to build solutions that empower citizens and communities to actively contribute to environmental monitoring through intuitive tools and engaging experiences.	\N	\N	$3,000+ in prizes	[]	Registration
34	Axcentra National Hackathon 2026	https://axcentra.in/?utm_source=chatgpt.com	\N	\N	\N	active	2026-08-01 21:21:19.478529	online	https://axcentra.in/logo-wolfram.png	Build innovative solutions, collaborate with talented developers, solve real-world problems, and compete for a ₹1 Lakh+ Prize Pool - over one unforgettable weekend. Register for Hackathon.	\N	\N	₹1 Lakh+ Prize Pool - over one unforgettable weekend	[]	Registration
41	International Innovation Challenge 3.0	https://unstop.com/hackathons/international-innovation-challenge-30-manipal-university-mu-jaipur-1702624	\N	\N	\N	active	2026-08-01 21:30:13.620929	Offline	https://d8it4huxumps7.cloudfront.net/uploads/images/6944ff9c88081_comp_award_trophy.svg	Participants can choose a problem statement based on any one of 10 themes mentioned in the official guidelines. Teams must submit their project in the form of a PPT of up to 9 slides, including optional code and video explaining the project. The submission deadline is August 11th, 2026 at 11:59 PM IST. Shortlisted teams will be invited for an offline round at Manipal University Jaipur.	\N	\N	₹ 7,00,000	[]	Registration
47	Brain Bolt – The Engineers Sprint : 2026 Edition	https://imece.asme-india.org/2026/student-engagements	\N	\N	\N	active	2026-08-01 21:38:07.385539	online	https://cdn.prod.website-files.com/6909d748d6a427ee4ed763e9_IMECE-white-2026.svg	This initiative brings together undergraduate engineering students from across India to solve real-world, industry-relevant challenges in a competitive, fast-paced environment. Participants will apply classroom concepts such as design principles, analytical thinking, and algorithms to practical scenarios, while developing essential skills like teamwork, adaptability, and decision-making.	\N	\N	₹3,00,000 for 1st prize; ₹2,00,000 for 2nd prize; ₹1,00,000 for 3rd prize	[]	Registration
52	Robotics Innovation Hackathon 2026 Round 1: Idea Submission	https://docs.google.com/forms/d/e/1FAIpQLSc1N_Yhw9SWJcbkf1Pwf8_Bkcuy5bXySHZ4hp9bCGCd1giY0w/formResponse	\N	\N	\N	active	2026-08-01 21:43:00.032873	online	https://www.gstatic.com/images/branding/googlelogo/svg/googlelogo_dark_clr_74x24px.svg	Round 1 submissions have now closed. Shortlisted teams will be notified via email and WhatsApp.	\N	\N	\N	[]	Registration
58	Kanad S.H.I.E.L.D. Cybersecurity Hackathon 2026	https://www.kanadshield.com/about.html	\N	\N	\N	active	2026-08-01 21:49:09.229094	online	https://www.kanadshield.com/assets/img/logo/kanadshield-logo.png	Kanad S.H.I.E.L.D. Cybersecurity Hackathon 2026 is an initiative by the Cyber Crime Branch of Ahmedabad City Police in collaboration with i-Hub Gujarat. The primary objective is to strengthen the cyber space world through advanced technology and bring together the nation's brightest startups, industries, tech experts & academics on a single platform to develop cutting-edge solutions for modern-day cyber threats.	\N	\N	\N	[]	Registration
64	Agentic AI Build Week 2026	https://agentic-ai-build-week-2026.devpost.com/	\N	\N	\N	active	2026-08-01 21:57:19.402214	online	https://s3.amazonaws.com/challengepost/sponsors/logos/000/048/536/highres/idanTsRSNX.png	The largest on-site AI buildathon in Southeast Asia, featuring 2,000+ builders, 10 enterprise partners, and the full AI stack in one room for five days in Ho Chi Minh City. Every challenge comes from a real enterprise partner, and every winning solution enters an active deployment conversation on Demo Day.	\N	\N	$1M USD in prizes, perks, tools, credits, and builder resources	[]	Registration
74	Queue Cure '26	https://unstop.com/hackathons/queue-cure-26-wooble-software-private-limited-1697413	\N	\N	\N	active	2026-08-01 22:09:57.962037	online	https://d8it4huxumps7.cloudfront.net/uploads/images/6944ff9c88081_comp_award_trophy.svg	A beginner-friendly Full Stack hackathon hosted on Wooble — India's portfolio-first hiring platform where builders get hired on what they build, not what their resume says. The goal is to create a solution that improves patient wait times and visibility for clinics.	\N	2026-06-25 12:58:00	\N	[]	Registration
35	DeepTech Bharat Hackathon 2026	https://docs.google.com/forms/d/e/1FAIpQLSfCopSbqjUYt-Oc6CCTo_wPjeAPUy9LV9k_PHJ-aELgdrWAQQ/viewform	\N	\N	\N	active	2026-08-01 21:21:40.166782	online	https://www.gstatic.com/images/branding/googlelogo/svg/googlelogo_dark_clr_74x24px.svg	This form is not accepting any responses. For any further query, please write to ninc@nec.org.in	\N	\N	\N	[]	Registration
42	Odoo x LDCE Ahmedabad Hackathon	https://hackathon.odoo.com/event/odoo-x-ldce-ahmedabad-hackathon-26-29/register	\N	\N	\N	active	2026-08-01 21:33:14.698642	online	https://www.odoo.com/web/image/81134593-9d0370dc/DSC01562.webp?access_token=82d23f55-a0b3-4886-9aaa-515dfc91805b	Join us for Hackathon, a 24-hour coding marathon where talent meets technology. Open for all tech students, freshers, and coding enthusiasts (Age: 18+). This is your golden opportunity to showcase your coding skills and push your limits.	2026-08-16 00:00:00	\N	₹45,000/- + Odoo Goodies + Certificate	[]	Registration
48	Youth for Climate Hackathon 2.0	https://southasia.iclei.org/hackathon-2026/	\N	\N	\N	active	2026-08-01 21:39:31.870052	online	https://southasia.iclei.org/wp-content/uploads/2025/12/Youth-Hackathon-Coverpage-1.jpg	The Youth and Sustainability team at ICLEI – Local Governments for Sustainability, South Asia, announces the launch of the 'Youth for Climate Hackathon 2.0'. In its second year, the hackathon is aligned with the evolving priorities of COP31: focusing on implementation, resilience, energy transition, and inclusive climate action. The hackathon seeks to bridge bold ideas with on-ground action through ICLEI's pathways for sustainable urban transitions.	\N	2026-10-28 00:00:00	Winners will receive prizes and certificates and an opportunity to present their innovative solutions at ARISE Cities Forum 2026.	[]	Registration
54	Bridgestone World Solar Challenge 2027	https://worldsolarchallenge.org/2027-event/team-registration	\N	\N	\N	active	2026-08-01 21:45:34.678931	online	https://assets.worldsolarchallenge.org/app/uploads/2024/10/04152934/3233_09338-copy.jpg	The Bridgestone World Solar Challenge is the world's greatest innovation and engineering challenge for sustainable mobility. Teams can apply in various classes including Challenger, Cruiser, Innovation, and Historic. Applications are now open until August 7, 2026 for early applications and October 9, 2026 for standard applications.	2026-10-09 23:59:59	\N	\N	[]	Registration
65	AI for Social Impact Challenge	http://form.startuptn.in/AISI	\N	\N	\N	active	2026-08-01 21:57:35.869151	online	https://www.gstatic.com/images/branding/googlelogo/svg/googlelogo_dark_clr_74x24px.svg	The AI for Social Impact Challenge form has been closed for responses.	\N	\N	\N	[]	Registration
70	Go Healthy with Taiwan 2026	https://gohealthy.taiwanexcellence.org/index.html#About	\N	\N	\N	active	2026-08-01 22:06:07.066989	online	https://gohealthy.taiwanexcellence.org/assets/images/index/one_box_title_tag01.png	The campaign aims to enhance global health and well-being through innovative solutions. It seeks proposals from all sectors, integrating Taiwanese products, solutions, or business models to make a real impact on local communities, cities, businesses, and organizations.	\N	\N	US$30,000 Prize	[]	Registration
76	IDBI Innovate 2026	https://hack2skill.com/event/idbinnovate/?utm_source=hack2skill&utm_medium=homepage&sectionid=6a25acee3b5d90996644544c	\N	\N	\N	active	2026-08-01 22:12:51.241358	online	https://storage.googleapis.com/vision-hack2skill-production/innovator/USER01338782/1781057394315-IDBIbannerFinal2.webp	A national-level innovation challenge that brings together the brightest minds in India's Startup and FinTech ecosystem to solve real-world banking problems — and build solutions scalable enough for deployment within IDBI Bank.	\N	2026-07-13 00:00:00	₹15,00,000 (Total Prize Pool • Distributed across all tracks)	[]	Registration
81	TechExpo - IIT Guwahati	https://unstop.com/competitions/techexpo-iit-guwahati-1695273	\N	\N	\N	active	2026-08-01 22:21:19.949221	online	https://d8it4huxumps7.cloudfront.net/uploads/images/150x150/6a4791f13ccc1_Asian_Paints.png?d=68x68	TechExpo is a national-level science and engineering project competition held annually at IIT Guwahati during its annual techno-management festival, Techniche. It provides a platform for students to transform innovative ideas into working prototypes by presenting their projects to a panel of industry experts, academicians, and professionals.	2026-08-28 12:00:00	\N	\N	[]	Registration
43	Odoo Hackathon 2026	https://hackathon.odoo.com/event/odoo-hackathon-2026-33/register	\N	\N	\N	active	2026-08-01 21:34:15.134677	online	https://hackathon.odoo.com/web/static/img/odoo_logo_tiny.png	Join us for Odoo Hackathon 2026, a 24-hour coding marathon where surprise problem statements will assess your coding skills. Whether you are a student, a fresher, or a coding enthusiast, this hackathon is designed to test your creativity, problem-solving abilities, and teamwork.	\N	\N	₹1,70,000/- + Odoo Goodies + Certificate	[]	Registration
49	IKIGAI 2026	https://unstop.com/hackathons/ikigai-2026-acropolis-institute-of-technology-and-research-indore-1703362	\N	\N	\N	active	2026-08-01 21:40:47.951429	online	https://d8it4huxumps7.cloudfront.net/uploads/images/opportunity/banner/6a3f9beae12c1_ikigai-2026.png?d=720x600	IKIGAI 2026 is a premier National Level Hackathon designed to bring together innovative minds, developers, designers, and problem-solvers from across the country. The event aims to foster creativity, inclusivity, and the practical application of emerging technologies while encouraging participants to solve real-world challenges through innovation and teamwork.	\N	2026-07-26 23:59:00	₹ 1,03,000	[]	Registration
55	Hackathon Name: Not Specified	https://docs.google.com/forms/d/e/1FAIpQLSdQpzPz2D8wMIqTLVDg7GvSbg6wFfxLV_78uKcyUFojaCiOMQ/viewform?clid=eyJpIjoiMndIWWFxdjVEZDZNbFNJQkJzN0hlIiwiaCI6IiIsInAiOiIvWFJESSIsInQiOjE3ODIzNjQyODZ9.iCm9ensmjD6IYDoENxxwrojvYG3Wqkn6mWkBLNYX4t0	\N	\N	\N	active	2026-08-01 21:46:00.158668	online	\N	Not specified	\N	\N	\N	[]	Registration
60	IEEE Makers R10 HTA Competition	https://ieeer10htadiy.org/	\N	\N	\N	active	2026-08-01 21:50:47.705937	online	\N	An international platform for students, researchers, and hobbyists under IEEE Region 10 to engineer open-source, affordable, and sustainable physical solutions for community humanitarian needs. Turn your maker ideas into impactful devices.	\N	\N	\N	[]	Registration
66	AI Product Challenge 2026	https://unstop.com/hackathons/ai-product-challenge-2026-dyndox-1700798	\N	\N	\N	active	2026-08-01 21:58:18.502862	online	https://d8it4huxumps7.cloudfront.net/uploads/images/150x150/6a342c17b7979_organisation_image-jDcDQqkA6o476496884u1LMymzQJi.png?d=200x200	The AI Product Challenge 2026 is a national-level innovation challenge for students, developers, creators, designers, and aspiring founders who want to build real AI-powered products and showcase their creativity. Participants will identify a real-world problem, design an innovative solution, and build an AI-powered product, tool, workflow, application, or platform.	\N	\N	\N	[]	Registration
71	HAC'KP 2026	https://hackp.kerala.gov.in/	\N	\N	\N	active	2026-08-01 22:07:41.477511	online	https://hackp.kerala.gov.in/assets/images/cyber_division_logo_w.png	HAC'KP 2026 is a national multi-city hackathon focused on building next-generation AI-powered solutions for digital investigations and advancing the future of cyber-enabled policing. The event aims to evolve from reactive response to proactive intelligence by embracing technology-driven innovation.	\N	\N	₹10 LAKHS+ PRIZE POOL | NATIONAL RECOGNITION | REAL-WORLD IMPACT	[]	Registration
77	NXP Cup India	https://www.nxp.com/company/about-nxp/events/nxp-cup-india:NXP-CUP-INDIA	\N	\N	\N	active	2026-08-01 22:15:58.717494	online	https://www.nxp.com/shared/oneTrust/oneTrust_production/consent/91cc4c7b-323c-4c7e-8374-340c1fe62aa2/4ac98e2f-3d99-47bd-8675-2d61b96d94f3/logos/static/powered_by_logo.svg	NXP Cup is an exciting platform for engineering students to design and create mobile robotics prototypes using cutting-edge technologies like AI/ML, object/sign recognition, sensors, motion detection, computer vision, and obstacle avoidance. The challenge aims to design Mobile Robotics Prototypes by integrating various sensors inputs like camera, Lidar, etc.	\N	\N	₹ 1,00,000 (Grand Finale prize), ₹ 75,000 (second place), ₹ 50,000 (third place)	[]	Registration
37	Unknown Title	https://cdac.in/index.aspx?id=ev_cdac_advertisement	\N	\N	\N	active	2026-08-01 21:25:40.050048	online	\N		\N	\N	\N	[]	Registration
1	Global AI Agents Sprint 2026	https://devpost.com/hackathons/global-ai-agents	\N	\N	\N	active	2026-08-01 19:25:00.804661	online	https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600	Build autonomous AI agents to solve real-world automation challenges using LLMs, multi-agent frameworks, and vector search.	2026-07-28 23:59:59	2026-08-01 09:00:00	\N	[]	Registration
2	Web3 Innovation Summit	https://ethglobal.com/events/innovation2026	\N	\N	\N	upcoming	2026-08-01 19:25:00.804661	online	https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=600	Develop decentralized applications, cross-chain smart contracts, and zero-knowledge privacy prototypes.	2026-08-05 23:59:59	2026-08-10 10:00:00	\N	[]	Registration
3	Robotics & Hardware Hackathon	https://idrea.org/robotic-challenge/	\N	\N	\N	upcoming	2026-08-01 19:25:00.804661	offline	https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=600	Build autonomous hardware controllers, ROS2 robotics nodes, and IoT sensory networks for smart logistics.	2026-08-15 23:59:59	2026-08-20 08:00:00	\N	[]	Registration
4	GreenTech Sustainable Code Challenge	https://greentech-hack.org	\N	\N	\N	open	2026-08-01 19:25:00.804661	online	https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=600	Design energy-efficient algorithms and climate tech carbon footprint monitoring dashboards.	2026-08-31 23:59:59	2026-07-18 10:00:00	\N	[]	Registration
5	National Level SSM Hackathon	https://ssm.cdac.in/hackathon	\N	\N	\N	active	2026-08-01 20:38:14.631042	online	https://ssm.cdac.in/images/cdaclogo.png	Two National Tracks. One Big Opportunity.\nCompete solo or as a team, present your solution to expert judges, and stand a chance to win big.\n₹20,00,000+ TOTAL PRIZE POOL	\N	2026-07-28 00:00:00	₹20,00,000+	[]	Registration
6	Unknown Title	https://www.mygov.in/task/indiaskills-mascot-design-competition	\N	\N	\N	active	2026-08-01 20:47:40.376963	online	\N		\N	\N	\N	[]	Registration
7	Build With Bharat 2.0	https://unstop.com/hackathons/build-with-bharat-40-national-institute-of-technology-nit-delhi-1719203	\N	\N	\N	active	2026-08-01 20:54:06.232788	Offline	https://d8it4huxumps7.cloudfront.net/uploads/images/opportunity/mobile_banner/6a58c8a56a17c_build-with-bharat-20.png?d=700x400	As part of the selection process, all registered teams are required to submit their project idea in the prescribed presentation format. The presentation should briefly describe your problem statement, proposed solution, technology stack, and expected impact. The hackathon brings together talented developers, designers, innovators, and problem-solvers from across the country to build impactful technology solutions for real-world challenges.	\N	\N	₹1,00,000	[]	Registration
8	Edge AI Hackathon 2026	https://edspmec.github.io/eds-pmec/hackathon.html	\N	\N	\N	active	2026-08-01 20:54:59.582736	online	\N	The Edge AI Hackathon 2026 is an elite hardware-centric sprint designed to foster local engineering innovation, with teams working under time constraints to address real-world application challenges and create optimized hardware solutions that utilize embedded intelligence at the sensor node. The hackathon features major focus themes such as Edge AI, Embedded Systems, IoT, TinyML, Semiconductor Applications, and Real-time AI.	\N	\N	\N	[]	Registration
9	0xCON 2026 - Students	https://unstop.com/workshops-webinars/0xcon-2026-students-chennai-institute-of-technology-1715813	\N	\N	\N	active	2026-08-01 20:55:45.171638	Offline	https://d8it4huxumps7.cloudfront.net/uploads/images/150x150/6a58d57ce5ece_Unstop-Logo-Blue-Large.png?d=68x68	The conference is designed to bring together students, cybersecurity professionals, researchers, industry experts, and technology enthusiasts for a day of technical learning, networking, and innovation. The event features keynote sessions, expert technical talks, hands-on workshops, cybersecurity villages, project showcases, sponsor exhibitions, networking opportunities, and community engagement activities.	\N	\N	\N	[]	Registration
11	Unknown Title	https://i4c.in/hackathon-2026/	\N	\N	\N	active	2026-08-01 20:57:34.907996	online	\N		\N	\N	\N	[]	Registration
12	HackNexus'26	https://hacknexus.droidecks.sbs/	\N	\N	\N	active	2026-08-01 20:58:43.000005	online	https://hacknexus.droidecks.sbs/width_834.webp	A national-level online hackathon for student innovators, consisting of three intense rounds where participants can turn their ideas into impactful solutions from anywhere in India.	2026-07-31 00:00:00	\N	₹70,000+	[]	Registration
13	Hackathon from aicraise.accubate.app	https://aicraise.accubate.app/ext/survey/17956/apply	\N	\N	\N	active	2026-08-01 20:58:45.655645	online	\N	...	2026-08-15 23:59:59	2026-08-20 09:00:00	\N	[]	Registration
14	MEDHA MEDITHON 2026 - REGISTRATION	https://docs.google.com/forms/d/e/1FAIpQLSfcqYoRoawi2dS0Q8UrvPCS4iZBTYHyDHFd4w0OcsGrrhI47Q/viewform	\N	\N	\N	active	2026-08-01 20:59:34.287321	online	https://www.gstatic.com/images/branding/googlelogo/svg/googlelogo_dark_clr_74x24px.svg	MEDHA MEDITHON 2026 is a premier medical hackathon organized by Leelatai Kulkarni Memorial Hospital & Research Center in association with BETiC (Biomedical Engineering and Technology Innovation Centre) IIT Bombay, V3 Foundation, Visvesvaraya National Institute of Technology (VNIT), Nagpur, and BETiC - GHRCE, Nagpur. The hackathon brings together students, healthcare professionals, innovators, engineers, designers, researchers, and entrepreneurs to collaborate on solving real-world healthcare challenges.	\N	\N	\N	[]	Registration
15	FANUC India – Internship Hiring for Robot Department (2026 - 2027)	https://forms.office.com/pages/responsepage.aspx?id=DylLX-c5NUGbd7XqwvEflCToQoamoedJrGDHWp2lA6hUOUxCRzhMMUtFT1k3Vjk2UUlYNDdHUDFPQS4u&route=shorturl	\N	\N	\N	active	2026-08-01 21:00:03.886455	online	https://forms.cloud.microsoft/cdn/images/microsoft365logo_v1.png	When you submit this form, it will not automatically collect your details like name and email address unless you provide it yourself. This content is created by the owner of the form. The data you submit will be sent to the form owner. Microsoft is not responsible for the privacy or security practices of its customers, including those of this form owner. Never give out your password.	\N	\N	\N	[]	Registration
16	36-Hour National Level Hackathon 2026	https://docs.google.com/forms/d/e/1FAIpQLSfQZyE__xZ7T2Dr-ma1EiBZtnShTzyD4uqeSnFuK8NuSeKixw/viewform	\N	\N	\N	active	2026-08-01 21:00:27.857472	online	https://www.gstatic.com/images/branding/googlelogo/svg/googlelogo_dark_clr_74x24px.svg	The form for the 36-Hour National Level Hackathon 2026 organized by TATA Centre for AI & ML at NITT is no longer accepting responses.	\N	\N	\N	[]	Registration
19	Unknown Title	https://pechacks.org/	\N	\N	\N	active	2026-08-01 21:04:25.938681	online	\N		\N	\N	\N	[]	Registration
20	IEEE WIE ILS 2026 National Hackathon	https://rimmi-10.github.io/ils2026-registration/	\N	\N	\N	active	2026-08-01 21:05:30.624939	Online, with an offline finale	\N	The IEEE Women in Engineering International Leadership Summit (WIE) ILS 2026 is a national hackathon held in Surat, India. The event consists of three rounds: Round 1 which is online and Registration Deadline is extended to August 10th, 2026; Round 2 which is also online and the Submission Deadline is September 15th, 2026; and Round 3, the Grand Finale, which is offline on October 25th, 2026. The hackathon aims to empower and inspire participants towards an inclusive and sustainable future for India.	2026-08-10 12:00:00	2026-10-25 12:00:00	Details not provided in the given text	[]	Registration
21	GBT BuildStorm 2026	https://unstop.com/hackathons/gbt-buildstorm-2026-go-beyond-tickets-1719425	\N	\N	\N	active	2026-08-01 21:06:16.906775	online	https://d8it4huxumps7.cloudfront.net/uploads/images/150x150/6a58d57ce5ece_Unstop-Logo-Blue-Large.png?d=68x68	GBT BuildStorm 2026 is an open innovation buildathon where ideas take shape into real products. There are no predefined themes and no technology restrictions. The competition welcomes students from all branches and all years. If you have an idea, build it. No limits. Just Build.	\N	2026-09-20 00:00:00	\N	[]	Registration
23	Janatics Automation Skill & Competency Challenge	https://www.jdls.in/event_jasc_2026.php	\N	\N	\N	active	2026-08-01 21:11:01.689416	Offline	https://www.jdls.in/assets/img/events/2026/header.png	The Janatics Automation Skill & Competency Challenge is an educational initiative by JANATICS to train students in automation skills and bridge the gap between academic education and industry demands.	\N	\N	Cash Prize, Special Recognition Awards	[]	Registration
24	TechNova: Igniting Brilliance (Season 3)	https://unstop.com/hackathons/technova-igniting-brilliance-season-3-enterprise-system-solutions-private-limited-1709421	\N	\N	\N	active	2026-08-01 21:11:49.453259	online	https://d8it4huxumps7.cloudfront.net/uploads/images/opportunity/banner/6a62fa22a5955_technova-igniting-brilliance-season-3.png?d=1024x297	This is a premier technology competition that empowers students to innovate with a purpose. It gives students the exposure to feel the real IT world before they actually step into it and challenges them with real social problems, igniting their passion for innovation to create exciting technology solutions that can disrupt the future for good. The event includes stages such as Qualifier, Grand Master, and Championship rounds, with specific dates and requirements provided.	\N	2026-08-26 10:00:00	₹ 2,00,000	[]	Registration
25	ZERO TO ONE AI Hackathon	https://hackculture.io/hackathons/zero-to-one	\N	\N	\N	active	2026-08-01 21:13:34.373126	Offline	https://hackcultureplatform.blob.core.windows.net/event-assets/hackathons/6a535ee69f8f79eb53149046/upload_1784436353104_us7e1h.webp	A 36-Hour Generative AI Media Hackathon in Bengaluru, India, featuring keynote sessions and live demos, where participants can learn directly from founders, AI leaders, and industry experts. The hackathon aims to help participants transform bold ideas into working products by solving real-world challenges at the intersection of AI, storytelling, audio, and media.	\N	2026-07-26 11:59:00	₹ 12,60,000	[]	Registration
26	Create in India Challenge Season 2	https://wavesbazaar.com/create-india-challenge/season2/ifp	\N	\N	\N	active	2026-08-01 21:14:24.333334	online	https://wavesbazaar.com/assets/images/cic/glimpse1.png	The Create in India Challenge (CIC) is an industry-driven and government-supported platform focused on identifying, nurturing, skilling, mentoring, and showcasing creative talent across diverse Media & Entertainment sectors. The initiative covers areas such as Animation, VFX, Online Social Gaming, Comics, XR, Films, Music, Broadcasting, AI and Digital Media. CIC aims to create a future-ready talent pool through structured challenges, industry mentorship, market linkages, and national and international showcasing opportunities for creators across India.	\N	\N	\N	[]	Registration
27	Indian Council of Social Science Research (ICSSR) Application Dashboard	https://app.icssr.org/	\N	\N	\N	active	2026-08-01 21:14:50.133461	online	https://app.icssr.org/assets/site/main/images/islrtc-logo.png	Apply for various grants, fellowships, and events through the ICSSR Application Dashboard. Note that the last dates for Doctoral Fellowships and Postdoctoral Fellowship/Senior Fellowship have been extended to August 04, 2026 and August 07, 2026 respectively.	2026-08-07 15:00:00	\N	\N	[]	Registration
28	ChatGPT Codex Hackathon 2026	https://blockseblock.com/hackathon_details/chatgpt-codex-hackathon-2026	\N	\N	\N	active	2026-08-01 21:15:51.667928	online	https://storage.googleapis.com/block_se_block/hackathon_image/1779961335041-Zomathon-%20Website%20banner%20(5).png	The ChatGPT Codex Hackathon 2026 is a national AI product-building challenge, bringing together developers, innovators, students, and founders to build AI-powered solutions using ChatGPT Codex by OpenAI. Participants will build real-world AI products across nine Innovation Tracks.	2026-08-03 23:59:00	\N	Top 5 winners will receive Codex Pro access for one year worth over ₹1.2L in value.	[]	Registration
29	Build with Gemma Hackathon - Pwani	https://gdg.community.dev/events/details/google-gdg-pwani-presents-build-with-gemma-hackathon-pwani/?shem=isphe	\N	\N	\N	active	2026-08-01 21:16:59.353115	online	https://res.cloudinary.com/startup-grind/image/upload/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/featured_attendees/20221004_121710.jpg	The next generation of open models is here. Welcome to the Gemma 4 Hackathon Sprint, a fast-paced, 1-day hybrid hackathon where you'll get hands-on with the most capable open models from Google DeepMind.	\N	2026-07-31 08:00:00	$2000	[]	Registration
30	Adobe University Hackathon 2026	https://unstop.com/hackathons/crp-adobe-university-hackathon-2026-adobe-1715333	\N	\N	\N	active	2026-08-01 21:17:55.875449	online	https://d8it4huxumps7.cloudfront.net/uploads/images/opportunity/banner/6a577d540878b_adobe-university-hackathon-2026.png?d=1024x1024	The Adobe University Hackathon 2026 is a competition where engineering students from across all years and branches are challenged to solve problems using AI, creativity, and problem-solving skills. The event spans over four stages with online assessments, development rounds, prototype showcases, and a grand finale presentation. Teams will have the opportunity to present their solutions to Adobe’s leadership at their headquarters in Noida.	\N	2026-08-09 22:00:00	\N	[]	Registration
38	HACK CORE 2026	https://www.annam.ai/hack-core/about	\N	\N	\N	active	2026-08-01 21:28:08.099109	online	https://res.cloudinary.com/dgwhmqdhr/image/upload/v1769143824/annam-white-with-icon_cp78pb.png	A collaboration built for impact between Syngenta Biologicals and ANNAM.AI, the IIT Ropar Centre of Excellence in AI for Agriculture. They aim to address one of agriculture's most pressing challenges - making biological solutions genuinely accessible and actionable for Indian farmers through an AI-enabled solution.	\N	\N	\N	[]	Registration
\.


--
-- Data for Name: leaderboard; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leaderboard (id, user_id, score, university, department, class_section, trend, win_streak) FROM stdin;
1	2	12500	MIT	Computer Science	Section A	up	3
2	3	11200	MIT	Computer Science	Section B	up	5
3	1	10850	Stanford	Engineering	Section A	down	0
\.


--
-- Data for Name: registrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.registrations (id, hackathon_id, user_id, status, registered_at) FROM stdin;
22	1	2	registered	2026-08-01 19:25:00.817283
23	2	2	registered	2026-08-01 19:25:00.817283
24	4	2	completed	2026-08-01 19:25:00.817283
\.


--
-- Data for Name: student_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.student_submissions (id, student_id, hackathon_id, proof_url, verification_status, ai_confidence, created_at) FROM stdin;
\.


--
-- Data for Name: submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.submissions (id, hackathon_id, user_id, proof_url, ai_status, ai_feedback, ai_confidence, submitted_at) FROM stdin;
2	4	2	https://github.com/alexrivers/greentech-dashboard	verified	VERIFIED: GreenTech Certificate template matched. Verified project submission repository & commit history.	0.98	2026-08-01 19:25:00.829903
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tasks (id, hackathon_id, user_id, title, description, due_date, status, created_at) FROM stdin;
6	1	2	Design UI System & Figma Wireframes	Create modern dark mode mockup and UI components for the agent dashboard.	2026-07-25 18:00:00	completed	2026-08-01 19:25:00.824106
7	1	2	Setup Vector DB & RAG Pipeline	Configure Pgvector or Pinecone indexing for fast knowledge extraction.	2026-07-27 12:00:00	in_progress	2026-08-01 19:25:00.824106
8	1	2	Build Gemini AI Verification Endpoint	Integrate multimodal vision verification for student certificate proofs.	2026-07-28 15:00:00	in_progress	2026-08-01 19:25:00.824106
9	1	2	Record 3-Minute Video Demo & Pitch Deck	Record loom video overview and prepare GitHub repository submission.	2026-07-28 20:00:00	todo	2026-08-01 19:25:00.824106
10	2	2	Smart Contract Audit & Testnet Deployment	Deploy ERC-721 credential verification contracts to Sepolia testnet.	2026-08-04 17:00:00	todo	2026-08-01 19:25:00.824106
\.


--
-- Data for Name: team_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.team_members (id, team_id, user_id, email, register_number, invite_status, proof_url, joined_at) FROM stdin;
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teams (id, name, hackathon_id, leader_id, status, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, role, avatar_url, created_at, password_hash, wins, skills, university, department, win_count) FROM stdin;
1	Sarah Chen	sarah.chen@hackbuddy.org	admin	https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150	2026-07-22 11:12:59.346054	$2b$10$osGyV1I6tBhawmknJyJDT.GGDNowSJKDkGQMkvly8pINjTUhIw7jC	0	{}	\N	\N	0
3	Marcus Vance	marcus.v@devs.io	student	https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150	2026-07-22 11:12:59.346054	$2b$10$osGyV1I6tBhawmknJyJDT.GGDNowSJKDkGQMkvly8pINjTUhIw7jC	0	{}	\N	\N	0
4	Harikesh S 	harikeshs.cse2024@citchennai.net	student	https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150	2026-08-04 21:29:26.376546	$2b$10$G7/PM6L0pvNDV75uq1CSyO2ynZuKIXwnGBkrelgPbe5pQkD6.Gdzu	0	{}	\N	\N	0
2	Alex Rivers	admin@citchennai.net	student	https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150	2026-07-22 11:12:59.346054	$2b$10$5/jvD.bE2TYC9Ss4RH.WXev.egXpjFrU1eT1e4Kp.NB/KPtfExCPe	7	{React,TypeScript,Node.js,Python,Tailwind}	\N	\N	0
5	GOWTHAM B CSE	gowthamb.cse2024@citchennai.net	student	https://lh3.googleusercontent.com/a/ACg8ocJEE9apY_oiJvwAWLvls8xTA3pn9rRKwbZV9aFdE5m-1SUgDw=s96-c	2026-08-05 09:15:27.47212	$2b$10$1D.iKvat1CDQkM70YUcUle/qA5OyJgMBI.HICwnNXiHQVNoPAarIO	0	{}	\N	\N	0
\.


--
-- Data for Name: winners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.winners (id, hackathon_id, user_id, team_id, won_at) FROM stdin;
\.


--
-- Name: hackathons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hackathons_id_seq', 86, true);


--
-- Name: leaderboard_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leaderboard_id_seq', 3, true);


--
-- Name: registrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.registrations_id_seq', 24, true);


--
-- Name: student_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.student_submissions_id_seq', 1, false);


--
-- Name: submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.submissions_id_seq', 2, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tasks_id_seq', 10, true);


--
-- Name: team_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.team_members_id_seq', 2, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.teams_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: winners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.winners_id_seq', 1, false);


--
-- Name: hackathons hackathons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hackathons
    ADD CONSTRAINT hackathons_pkey PRIMARY KEY (id);


--
-- Name: hackathons hackathons_source_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hackathons
    ADD CONSTRAINT hackathons_source_url_key UNIQUE (source_url);


--
-- Name: leaderboard leaderboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaderboard
    ADD CONSTRAINT leaderboard_pkey PRIMARY KEY (id);


--
-- Name: registrations registrations_hackathon_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_hackathon_id_user_id_key UNIQUE (hackathon_id, user_id);


--
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: student_submissions student_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_submissions
    ADD CONSTRAINT student_submissions_pkey PRIMARY KEY (id);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_team_id_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_team_id_email_key UNIQUE (team_id, email);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: winners winners_hackathon_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_hackathon_id_user_id_key UNIQUE (hackathon_id, user_id);


--
-- Name: winners winners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_pkey PRIMARY KEY (id);


--
-- Name: leaderboard leaderboard_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leaderboard
    ADD CONSTRAINT leaderboard_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: registrations registrations_hackathon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_hackathon_id_fkey FOREIGN KEY (hackathon_id) REFERENCES public.hackathons(id) ON DELETE CASCADE;


--
-- Name: registrations registrations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_submissions student_submissions_hackathon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_submissions
    ADD CONSTRAINT student_submissions_hackathon_id_fkey FOREIGN KEY (hackathon_id) REFERENCES public.hackathons(id);


--
-- Name: submissions submissions_hackathon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_hackathon_id_fkey FOREIGN KEY (hackathon_id) REFERENCES public.hackathons(id) ON DELETE CASCADE;


--
-- Name: submissions submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_hackathon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_hackathon_id_fkey FOREIGN KEY (hackathon_id) REFERENCES public.hackathons(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_members team_members_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: team_members team_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: teams teams_hackathon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_hackathon_id_fkey FOREIGN KEY (hackathon_id) REFERENCES public.hackathons(id) ON DELETE CASCADE;


--
-- Name: teams teams_leader_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_leader_id_fkey FOREIGN KEY (leader_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: winners winners_hackathon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_hackathon_id_fkey FOREIGN KEY (hackathon_id) REFERENCES public.hackathons(id) ON DELETE CASCADE;


--
-- Name: winners winners_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: winners winners_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.winners
    ADD CONSTRAINT winners_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict d0Fe7jqrVAwN3ZW2dDa8PsyqLWlgxypXQs7yovHd8cfnw6fa3AFVKUMNVlY9sQ4

