--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: postgis; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA postgis;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA postgis;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: pc_chartoint(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pc_chartoint(chartoconvert character varying) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT CASE WHEN trim($1) SIMILAR TO '[0-9]+'
            THEN CAST(trim($1) AS integer)
        ELSE NULL END;

    $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: blast_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE blast_emails (
    id integer NOT NULL,
    petition_id integer,
    from_name character varying(255) NOT NULL,
    from_address character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text NOT NULL,
    delayed_job_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    recipient_count integer,
    moderation_status character varying(255) DEFAULT 'pending'::character varying,
    delivery_status character varying(255) DEFAULT 'pending'::character varying,
    moderated_at timestamp without time zone,
    moderation_reason text,
    type character varying(255),
    group_id integer,
    organisation_id integer
);


--
-- Name: blast_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE blast_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blast_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE blast_emails_id_seq OWNED BY blast_emails.id;


--
-- Name: campaign_admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE campaign_admins (
    id integer NOT NULL,
    petition_id integer,
    user_id integer,
    invitation_email character varying(255),
    invitation_token character varying(60)
);


--
-- Name: campaign_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE campaign_admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE campaign_admins_id_seq OWNED BY campaign_admins.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organisation_id integer,
    slug character varying(255),
    external_id character varying(255)
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: categorized_efforts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categorized_efforts (
    id integer NOT NULL,
    category_id integer,
    effort_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categorized_efforts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categorized_efforts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorized_efforts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categorized_efforts_id_seq OWNED BY categorized_efforts.id;


--
-- Name: categorized_petitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categorized_petitions (
    id integer NOT NULL,
    category_id integer,
    petition_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categorized_petitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categorized_petitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorized_petitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categorized_petitions_id_seq OWNED BY categorized_petitions.id;


--
-- Name: contents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contents (
    id integer NOT NULL,
    organisation_id integer,
    slug character varying(255),
    name character varying(255),
    category character varying(255),
    body text,
    filter character varying(255) DEFAULT 'none'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    kind character varying(255) DEFAULT 'text'::character varying
);


--
-- Name: contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contents_id_seq OWNED BY contents.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: efforts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE efforts (
    id integer NOT NULL,
    organisation_id integer,
    title character varying(255),
    slug character varying(255),
    description text,
    gutter_text text,
    title_help text,
    title_label character varying(255),
    title_default text,
    who_help text,
    who_label character varying(255),
    who_default text,
    what_help text,
    what_label character varying(255),
    what_default text,
    why_help text,
    why_label character varying(255),
    why_default text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    thanks_for_creating_email text,
    ask_for_location boolean,
    effort_type character varying(255) DEFAULT 'open_ended'::character varying,
    leader_duties_text text,
    how_this_works_text text,
    training_text text,
    training_sidebar_text text,
    distance_limit integer DEFAULT 100,
    prompt_edit_individual_petition boolean DEFAULT false,
    featured boolean DEFAULT false,
    image_default_file_name character varying(255),
    image_default_content_type character varying(255),
    image_default_file_size integer,
    image_default_updated_at timestamp without time zone,
    landing_page_welcome_text text
);


--
-- Name: efforts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE efforts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: efforts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE efforts_id_seq OWNED BY efforts.id;


--
-- Name: email_white_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_white_lists (
    id integer NOT NULL,
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_white_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_white_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_white_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_white_lists_id_seq OWNED BY email_white_lists.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE emails (
    id integer NOT NULL,
    to_address character varying(255) NOT NULL,
    from_name character varying(255) NOT NULL,
    from_address character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;


--
-- Name: facebook_share_widget_shares; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE facebook_share_widget_shares (
    id integer NOT NULL,
    user_facebook_id character varying(255),
    friend_facebook_id character varying(255),
    url character varying(255),
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: facebook_share_widget_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facebook_share_widget_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facebook_share_widget_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facebook_share_widget_shares_id_seq OWNED BY facebook_share_widget_shares.id;


--
-- Name: geographies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geographies (
    id integer NOT NULL,
    shape postgis.geography(GeometryZ,4326)
);


--
-- Name: geographies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geographies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geographies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geographies_id_seq OWNED BY geographies.id;


--
-- Name: group_blast_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_blast_emails (
    id integer NOT NULL,
    group_id integer,
    from_name character varying(255) NOT NULL,
    from_address character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text NOT NULL,
    delayed_job_id integer,
    recipient_count integer,
    moderation_status character varying(255) DEFAULT 'pending'::character varying,
    delivery_status character varying(255) DEFAULT 'pending'::character varying,
    moderated_at timestamp without time zone,
    moderation_reason text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_blast_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_blast_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_blast_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_blast_emails_id_seq OWNED BY group_blast_emails.id;


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_members (
    id integer NOT NULL,
    group_id integer,
    user_id integer,
    invitation_email character varying(255),
    invitation_token character varying(60)
);


--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_members_id_seq OWNED BY group_members.id;


--
-- Name: group_subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_subscriptions (
    id integer NOT NULL,
    group_id integer,
    member_id integer,
    unsubscribed_at timestamp without time zone,
    token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_subscriptions_id_seq OWNED BY group_subscriptions.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    organisation_id integer,
    title character varying(255),
    slug character varying(255),
    description text,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    settings text
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE locations (
    id integer NOT NULL,
    query character varying(255),
    latitude numeric(13,10),
    longitude numeric(13,10),
    street character varying(255),
    locality character varying(255),
    postal_code character varying(255),
    country character varying(255),
    region character varying(255),
    warning character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extras text,
    geography_id integer
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE members (
    id integer NOT NULL,
    email character varying(255),
    organisation_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE members_id_seq OWNED BY members.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organisations (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(255),
    host character varying(255),
    contact_email character varying(255),
    parent_name character varying(255),
    admin_email character varying(255),
    google_analytics_tracking_id character varying(255),
    blog_link character varying(255),
    notification_url character varying(255),
    sendgrid_username character varying(255),
    sendgrid_password character varying(255),
    campaigner_feedback_link character varying(255),
    user_feedback_link character varying(255),
    use_white_list boolean DEFAULT false,
    parent_url character varying(255),
    facebook_url character varying(255),
    twitter_account_name character varying(255),
    settings text,
    uservoice_widget_link character varying(255)
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organisations_id_seq OWNED BY organisations.id;


--
-- Name: petition_flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petition_flags (
    id integer NOT NULL,
    petition_id integer,
    user_id integer,
    ip_address character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reason text
);


--
-- Name: petition_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petition_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petition_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petition_flags_id_seq OWNED BY petition_flags.id;


--
-- Name: petitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE petitions (
    id integer NOT NULL,
    title character varying(255),
    who character varying(255),
    why text,
    what text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    slug character varying(255),
    organisation_id integer NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    delivery_details text,
    cancelled boolean DEFAULT false NOT NULL,
    token character varying(255),
    admin_status character varying(255) DEFAULT 'unreviewed'::character varying,
    launched boolean DEFAULT false NOT NULL,
    campaigner_contactable boolean DEFAULT true,
    admin_reason text,
    administered_at timestamp without time zone,
    effort_id integer,
    admin_notes text,
    source character varying(255),
    group_id integer,
    location_id integer,
    petition_letter_file_name character varying(255),
    petition_letter_content_type character varying(255),
    petition_letter_file_size integer,
    petition_letter_updated_at timestamp without time zone,
    alias character varying(255),
    achievements text,
    bsd_constituent_group_id character varying(255),
    target_id integer
);


--
-- Name: petitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE petitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: petitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE petitions_id_seq OWNED BY petitions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: signatures; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signatures (
    id integer NOT NULL,
    petition_id integer,
    email character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    phone_number character varying(255),
    postcode character varying(255),
    created_at timestamp without time zone,
    join_organisation boolean,
    deleted_at timestamp without time zone,
    token character varying(255),
    unsubscribe_at timestamp without time zone,
    external_constituent_id character varying(255),
    member_id integer,
    additional_fields hstore,
    cached_organisation_slug character varying(255)
);


--
-- Name: signatures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE signatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE signatures_id_seq OWNED BY signatures.id;


--
-- Name: simple_captcha_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simple_captcha_data (
    id integer NOT NULL,
    key character varying(40),
    value character varying(6),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simple_captcha_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simple_captcha_data_id_seq OWNED BY simple_captcha_data.id;


--
-- Name: stories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stories (
    id integer NOT NULL,
    title character varying(255),
    content text,
    featured boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_file_name character varying(255),
    image_content_type character varying(255),
    image_file_size integer,
    image_updated_at timestamp without time zone,
    organisation_id integer,
    link character varying(255)
);


--
-- Name: stories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stories_id_seq OWNED BY stories.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255),
    tagger_id integer,
    tagger_type character varying(255),
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: targets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE targets (
    id integer NOT NULL,
    name character varying(255),
    phone_number character varying(255),
    email character varying(255),
    location_id integer,
    organisation_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(255)
);


--
-- Name: targets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE targets_id_seq OWNED BY targets.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    admin boolean,
    phone_number character varying(255),
    postcode character varying(255),
    join_organisation boolean,
    organisation_id integer NOT NULL,
    org_admin boolean DEFAULT false,
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    opt_out_site_email boolean,
    facebook_id character varying(255),
    external_constituent_id character varying(255),
    member_id integer,
    additional_fields hstore,
    cached_organisation_slug character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vanity_conversions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vanity_conversions (
    id integer NOT NULL,
    vanity_experiment_id integer,
    alternative integer,
    conversions integer
);


--
-- Name: vanity_conversions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vanity_conversions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vanity_conversions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vanity_conversions_id_seq OWNED BY vanity_conversions.id;


--
-- Name: vanity_experiments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vanity_experiments (
    id integer NOT NULL,
    experiment_id character varying(255),
    outcome integer,
    created_at timestamp without time zone,
    completed_at timestamp without time zone
);


--
-- Name: vanity_experiments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vanity_experiments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vanity_experiments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vanity_experiments_id_seq OWNED BY vanity_experiments.id;


--
-- Name: vanity_metric_values; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vanity_metric_values (
    id integer NOT NULL,
    vanity_metric_id integer,
    index integer,
    value integer,
    date character varying(255)
);


--
-- Name: vanity_metric_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vanity_metric_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vanity_metric_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vanity_metric_values_id_seq OWNED BY vanity_metric_values.id;


--
-- Name: vanity_metrics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vanity_metrics (
    id integer NOT NULL,
    metric_id character varying(255),
    updated_at timestamp without time zone
);


--
-- Name: vanity_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vanity_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vanity_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vanity_metrics_id_seq OWNED BY vanity_metrics.id;


--
-- Name: vanity_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vanity_participants (
    id integer NOT NULL,
    experiment_id character varying(255),
    identity character varying(255),
    shown integer,
    seen integer,
    converted integer
);


--
-- Name: vanity_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vanity_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vanity_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vanity_participants_id_seq OWNED BY vanity_participants.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY blast_emails ALTER COLUMN id SET DEFAULT nextval('blast_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY campaign_admins ALTER COLUMN id SET DEFAULT nextval('campaign_admins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categorized_efforts ALTER COLUMN id SET DEFAULT nextval('categorized_efforts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categorized_petitions ALTER COLUMN id SET DEFAULT nextval('categorized_petitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contents ALTER COLUMN id SET DEFAULT nextval('contents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY efforts ALTER COLUMN id SET DEFAULT nextval('efforts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_white_lists ALTER COLUMN id SET DEFAULT nextval('email_white_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facebook_share_widget_shares ALTER COLUMN id SET DEFAULT nextval('facebook_share_widget_shares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geographies ALTER COLUMN id SET DEFAULT nextval('geographies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_blast_emails ALTER COLUMN id SET DEFAULT nextval('group_blast_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_members ALTER COLUMN id SET DEFAULT nextval('group_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_subscriptions ALTER COLUMN id SET DEFAULT nextval('group_subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisations ALTER COLUMN id SET DEFAULT nextval('organisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petition_flags ALTER COLUMN id SET DEFAULT nextval('petition_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY petitions ALTER COLUMN id SET DEFAULT nextval('petitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY signatures ALTER COLUMN id SET DEFAULT nextval('signatures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simple_captcha_data ALTER COLUMN id SET DEFAULT nextval('simple_captcha_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stories ALTER COLUMN id SET DEFAULT nextval('stories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY targets ALTER COLUMN id SET DEFAULT nextval('targets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vanity_conversions ALTER COLUMN id SET DEFAULT nextval('vanity_conversions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vanity_experiments ALTER COLUMN id SET DEFAULT nextval('vanity_experiments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vanity_metric_values ALTER COLUMN id SET DEFAULT nextval('vanity_metric_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vanity_metrics ALTER COLUMN id SET DEFAULT nextval('vanity_metrics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vanity_participants ALTER COLUMN id SET DEFAULT nextval('vanity_participants_id_seq'::regclass);


--
-- Name: campaign_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY campaign_admins
    ADD CONSTRAINT campaign_admins_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categorized_efforts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categorized_efforts
    ADD CONSTRAINT categorized_efforts_pkey PRIMARY KEY (id);


--
-- Name: categorized_petitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categorized_petitions
    ADD CONSTRAINT categorized_petitions_pkey PRIMARY KEY (id);


--
-- Name: contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: efforts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY efforts
    ADD CONSTRAINT efforts_pkey PRIMARY KEY (id);


--
-- Name: email_white_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_white_lists
    ADD CONSTRAINT email_white_lists_pkey PRIMARY KEY (id);


--
-- Name: emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: facebook_share_widget_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY facebook_share_widget_shares
    ADD CONSTRAINT facebook_share_widget_shares_pkey PRIMARY KEY (id);


--
-- Name: geographies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geographies
    ADD CONSTRAINT geographies_pkey PRIMARY KEY (id);


--
-- Name: group_blast_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_blast_emails
    ADD CONSTRAINT group_blast_emails_pkey PRIMARY KEY (id);


--
-- Name: group_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_subscriptions
    ADD CONSTRAINT group_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_members
    ADD CONSTRAINT groups_users_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: members_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: petition_blast_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blast_emails
    ADD CONSTRAINT petition_blast_emails_pkey PRIMARY KEY (id);


--
-- Name: petition_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petition_flags
    ADD CONSTRAINT petition_flags_pkey PRIMARY KEY (id);


--
-- Name: petitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY petitions
    ADD CONSTRAINT petitions_pkey PRIMARY KEY (id);


--
-- Name: signatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signatures
    ADD CONSTRAINT signatures_pkey PRIMARY KEY (id);


--
-- Name: simple_captcha_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simple_captcha_data
    ADD CONSTRAINT simple_captcha_data_pkey PRIMARY KEY (id);


--
-- Name: stories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stories
    ADD CONSTRAINT stories_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vanity_conversions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vanity_conversions
    ADD CONSTRAINT vanity_conversions_pkey PRIMARY KEY (id);


--
-- Name: vanity_experiments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vanity_experiments
    ADD CONSTRAINT vanity_experiments_pkey PRIMARY KEY (id);


--
-- Name: vanity_metric_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vanity_metric_values
    ADD CONSTRAINT vanity_metric_values_pkey PRIMARY KEY (id);


--
-- Name: vanity_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vanity_metrics
    ADD CONSTRAINT vanity_metrics_pkey PRIMARY KEY (id);


--
-- Name: vanity_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vanity_participants
    ADD CONSTRAINT vanity_participants_pkey PRIMARY KEY (id);


--
-- Name: by_effort_id_and_target_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_effort_id_and_target_id ON petitions USING btree (effort_id, target_id);


--
-- Name: by_experiment_id_and_alternative; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_experiment_id_and_alternative ON vanity_conversions USING btree (vanity_experiment_id, alternative);


--
-- Name: by_experiment_id_and_converted; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_experiment_id_and_converted ON vanity_participants USING btree (experiment_id, converted);


--
-- Name: by_experiment_id_and_identity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_experiment_id_and_identity ON vanity_participants USING btree (experiment_id, identity);


--
-- Name: by_experiment_id_and_seen; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_experiment_id_and_seen ON vanity_participants USING btree (experiment_id, seen);


--
-- Name: by_experiment_id_and_shown; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_experiment_id_and_shown ON vanity_participants USING btree (experiment_id, shown);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: existing_signatures; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX existing_signatures ON signatures USING btree (petition_id) WHERE (deleted_at IS NULL);


--
-- Name: homepage_optimization; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX homepage_optimization ON petitions USING btree (organisation_id, admin_status, launched, cancelled, user_id, updated_at DESC);


--
-- Name: idx_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_key ON simple_captcha_data USING btree (key);


--
-- Name: index_campaign_admins_on_petition_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaign_admins_on_petition_id_and_user_id ON campaign_admins USING btree (petition_id, user_id);


--
-- Name: index_campaign_admins_on_user_id_and_petition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_campaign_admins_on_user_id_and_petition_id ON campaign_admins USING btree (user_id, petition_id);


--
-- Name: index_categories_on_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_organisation_id ON categories USING btree (organisation_id);


--
-- Name: index_categories_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_slug ON categories USING btree (slug);


--
-- Name: index_categorized_petitions_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categorized_petitions_on_category_id ON categorized_petitions USING btree (category_id);


--
-- Name: index_contents_on_category; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contents_on_category ON contents USING btree (category);


--
-- Name: index_contents_on_slug_and_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_contents_on_slug_and_organisation_id ON contents USING btree (slug, organisation_id);


--
-- Name: index_efforts_on_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_efforts_on_organisation_id ON efforts USING btree (organisation_id);


--
-- Name: index_efforts_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_efforts_on_slug ON efforts USING btree (slug);


--
-- Name: index_email_white_lists_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_white_lists_on_email ON email_white_lists USING btree (email);


--
-- Name: index_geographies_on_shape; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_geographies_on_shape ON geographies USING gist (shape);


--
-- Name: index_group_members_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_members_on_group_id_and_user_id ON group_members USING btree (group_id, user_id);


--
-- Name: index_group_members_on_user_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_members_on_user_id_and_group_id ON group_members USING btree (user_id, group_id);


--
-- Name: index_group_subscriptions_on_group_id_and_unsubscribed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_subscriptions_on_group_id_and_unsubscribed_at ON group_subscriptions USING btree (group_id, unsubscribed_at);


--
-- Name: index_group_subscriptions_on_member_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_group_subscriptions_on_member_id_and_group_id ON group_subscriptions USING btree (member_id, group_id);


--
-- Name: index_group_subscriptions_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_subscriptions_on_token ON group_subscriptions USING btree (token);


--
-- Name: index_groups_on_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_organisation_id ON groups USING btree (organisation_id);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_slug ON groups USING btree (slug);


--
-- Name: index_locations_on_geography_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_geography_id ON locations USING btree (geography_id);


--
-- Name: index_locations_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_latitude_and_longitude ON locations USING btree (latitude, longitude);


--
-- Name: index_locations_on_query; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_locations_on_query ON locations USING btree (query);


--
-- Name: index_organisations_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organisations_on_slug ON organisations USING btree (slug);


--
-- Name: index_petition_blast_emails_on_petition_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_blast_emails_on_petition_id_and_created_at ON blast_emails USING btree (petition_id, created_at);


--
-- Name: index_petition_flags_on_ip_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_flags_on_ip_address ON petition_flags USING btree (ip_address);


--
-- Name: index_petition_flags_on_petition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_flags_on_petition_id ON petition_flags USING btree (petition_id);


--
-- Name: index_petition_flags_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petition_flags_on_user_id ON petition_flags USING btree (user_id);


--
-- Name: index_petitions_on_effort_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petitions_on_effort_id ON petitions USING btree (effort_id);


--
-- Name: index_petitions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petitions_on_group_id ON petitions USING btree (group_id);


--
-- Name: index_petitions_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petitions_on_location_id ON petitions USING btree (location_id);


--
-- Name: index_petitions_on_organisation_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petitions_on_organisation_id_and_user_id ON petitions USING btree (organisation_id, user_id);


--
-- Name: index_petitions_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_petitions_on_slug ON petitions USING btree (slug);


--
-- Name: index_petitions_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_petitions_on_token ON petitions USING btree (token);


--
-- Name: index_petitions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_petitions_on_user_id ON petitions USING btree (user_id);


--
-- Name: index_signatures_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_signatures_on_member_id ON signatures USING btree (member_id);


--
-- Name: index_signatures_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_signatures_on_token ON signatures USING btree (token);


--
-- Name: index_stories_on_organisation_id_and_featured; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stories_on_organisation_id_and_featured ON stories USING btree (organisation_id, featured);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_targets_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_targets_on_location_id ON targets USING btree (location_id);


--
-- Name: index_targets_on_organisation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_targets_on_organisation_id ON targets USING btree (organisation_id);


--
-- Name: index_users_on_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_member_id ON users USING btree (member_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_vanity_experiments_on_experiment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vanity_experiments_on_experiment_id ON vanity_experiments USING btree (experiment_id);


--
-- Name: index_vanity_metric_values_on_vanity_metric_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vanity_metric_values_on_vanity_metric_id ON vanity_metric_values USING btree (vanity_metric_id);


--
-- Name: index_vanity_metrics_on_metric_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vanity_metrics_on_metric_id ON vanity_metrics USING btree (metric_id);


--
-- Name: index_vanity_participants_on_experiment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vanity_participants_on_experiment_id ON vanity_participants USING btree (experiment_id);


--
-- Name: lower_case_members_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX lower_case_members_email ON members USING btree (lower((email)::text), organisation_id);


--
-- Name: lower_case_organisations_host; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX lower_case_organisations_host ON organisations USING btree (lower((host)::text));


--
-- Name: lower_case_signatures_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX lower_case_signatures_email ON signatures USING btree (lower((email)::text), petition_id, deleted_at);


--
-- Name: lower_case_users_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX lower_case_users_email ON users USING btree (lower((email)::text), organisation_id);


--
-- Name: name_autocomplete; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX name_autocomplete ON targets USING btree (lower((name)::text) varchar_pattern_ops);


--
-- Name: org_petitions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX org_petitions ON petitions USING btree (organisation_id, created_at) WHERE (user_id IS NOT NULL);


--
-- Name: recent_signatures_desc; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX recent_signatures_desc ON signatures USING btree (created_at DESC, petition_id, deleted_at);


--
-- Name: target_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX target_name ON targets USING btree (name);


--
-- Name: target_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX target_slug ON targets USING btree (slug);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: unique_share; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_share ON facebook_share_widget_shares USING btree (user_facebook_id, friend_facebook_id, url);


--
-- Name: visible_petitions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX visible_petitions ON signatures USING btree (petition_id, deleted_at, unsubscribe_at);


SET search_path = postgis, pg_catalog;

--
-- Name: geometry_columns_delete; Type: RULE; Schema: postgis; Owner: -
--

CREATE RULE geometry_columns_delete AS ON DELETE TO geometry_columns DO INSTEAD NOTHING;


--
-- Name: geometry_columns_insert; Type: RULE; Schema: postgis; Owner: -
--

CREATE RULE geometry_columns_insert AS ON INSERT TO geometry_columns DO INSTEAD NOTHING;


--
-- Name: geometry_columns_update; Type: RULE; Schema: postgis; Owner: -
--

CREATE RULE geometry_columns_update AS ON UPDATE TO geometry_columns DO INSTEAD NOTHING;


--
-- PostgreSQL database dump complete
--

