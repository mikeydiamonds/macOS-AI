-- =============================================================================
-- Database Initialization Script
-- Creates separate databases for each service that needs PostgreSQL
-- =============================================================================

-- This script runs automatically when PostgreSQL container starts for the first time
-- via the docker-entrypoint-initdb.d mechanism

-- Create database for Firecrawl web scraping service
CREATE DATABASE firecrawl;

-- Create database for n8n workflow automation
CREATE DATABASE n8n;

-- Create database for Supabase backend platform
-- Note: Supabase may use its own internal Postgres instance instead
CREATE DATABASE supabase;

-- Grant all privileges on these databases to the postgres user
-- (Additional users can be created by each service as needed)
GRANT ALL PRIVILEGES ON DATABASE firecrawl TO postgres;
GRANT ALL PRIVILEGES ON DATABASE n8n TO postgres;
GRANT ALL PRIVILEGES ON DATABASE supabase TO postgres;
