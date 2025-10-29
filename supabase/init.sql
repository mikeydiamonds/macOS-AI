-- Supabase Database Initialization
-- Creates required schemas and roles for Supabase services

-- Auth schema for GoTrue authentication service
CREATE SCHEMA IF NOT EXISTS auth;

-- Storage schema for file storage metadata
CREATE SCHEMA IF NOT EXISTS storage;

-- Realtime schema for real-time subscriptions
CREATE SCHEMA IF NOT EXISTS realtime;

-- Create Supabase roles
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN NOINHERIT;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
  END IF;
END
$$;

-- Grant necessary permissions to postgres
GRANT USAGE ON SCHEMA auth TO postgres;
GRANT USAGE ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA realtime TO postgres;

GRANT ALL ON SCHEMA auth TO postgres;
GRANT ALL ON SCHEMA storage TO postgres;
GRANT ALL ON SCHEMA realtime TO postgres;

-- Grant permissions to Supabase roles
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO anon, authenticated, service_role;
