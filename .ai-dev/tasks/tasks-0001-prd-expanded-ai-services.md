# Task List: Expanded macOS-AI Services Stack

## Relevant Files

### Infrastructure & Configuration
- `.gitignore` - Updated with comprehensive ignore rules for .env files, data directories, and secrets
- `compose.yaml` - Will be replaced by modular docker-compose.yml files in service directories
- `setup.sh` - Main installation script with prerequisite checks and configuration workflow
- `SECRETS.md` - Auto-generated file documenting all random secrets (gitignored)
- `README.md` - Comprehensive documentation with quick start and service guides

### Common Services (PostgreSQL + Redis)
- `common/docker-compose.yml` - Shared database and cache services
- `common/.env.example` - Template for PostgreSQL/Redis configuration
- `common/postgres_data/.gitkeep` - Preserve directory structure
- `common/redis_data/.gitkeep` - Preserve directory structure
- `common/init-db.sql` - Database initialization script for creating service databases

### Traefik (Reverse Proxy)
- `traefik/docker-compose.yml` - Reverse proxy with routing for all services
- `traefik/.env.example` - Optional Traefik configuration

### Open WebUI (Enhanced)
- `open-webui/docker-compose.yml` - Modular compose file for chat interface
- `open-webui/.env.example` - Configuration template with Qdrant integration
- `open-webui/data/.gitkeep` - Preserve data directory

### SearXNG (Optimized)
- `searxng/docker-compose.yml` - Modular compose file for search engine
- `searxng/.env.example` - Configuration template with secret key
- `searxng/settings.yml` - Keep existing settings file tracked

### Crawl4ai
- `crawl4ai/docker-compose.yml` - AI-powered web crawler with Ollama integration
- `crawl4ai/.env.example` - Configuration with LLM provider settings
- `crawl4ai/Dockerfile` - Custom image with Xvfb for headless browser
- `crawl4ai/data/.gitkeep` - Preserve data directory
- `crawl4ai/shm/.gitkeep` - Preserve shared memory directory

### Docling
- `docling/docker-compose.yml` - Document processing service
- `docling/.env.example` - Configuration template
- `docling/data/.gitkeep` - Preserve temporary files directory

### Firecrawl
- `firecrawl/docker-compose.yml` - Web scraping API with Playwright and database
- `firecrawl/.env.example` - Comprehensive configuration with Ollama, database, search
- `firecrawl/data/.gitkeep` - Preserve storage directory

### n8n (Workflow Automation)
- `n8n/docker-compose.yml` - Main n8n service and worker with PostgreSQL/Redis
- `n8n/.env.example` - Configuration with database, Ollama, and worker settings
- `n8n/data/.gitkeep` - Preserve workflows and data directory

### Qdrant (Vector Database)
- `qdrant/docker-compose.yml` - Vector database for embeddings
- `qdrant/.env.example` - Configuration template
- `qdrant/storage/.gitkeep` - Preserve vector storage directory

### Scriberr (Transcription)
- `scriberr/docker-compose.yml` - Audio/video transcription service (CPU-based)
- `scriberr/.env.example` - Configuration template
- `scriberr/data/.gitkeep` - Preserve transcription data directory

### Supabase (Backend Platform)
- `supabase/docker-compose.yml` - Full Supabase stack (Studio, Kong, GoTrue, etc.)
- `supabase/.env.example` - Comprehensive configuration with JWT secrets and database
- `supabase/data/.gitkeep` - Preserve Supabase volumes directory

### Notes
- Each service maintains its own modular docker-compose.yml file for easy enabling/disabling
- .env.example files contain detailed documentation with REQUIRED, AUTO-GENERATED, and OPTIONAL markers
- Setup script handles copying .env.example to .env and populating auto-generated values
- Reference homelab templates at `/Users/mpruitt/projects/homelab/roles/stack/templates/` for proven patterns

## Tasks

- [x] 1.0 Update Project Structure and Git Configuration
  - [x] 1.1 Update `.gitignore` with comprehensive rules for .env files (`**/.env`, `*.env`), SECRETS.md, and all service data directories
  - [x] 1.2 Create directory structure for all new services (common, traefik, crawl4ai, docling, firecrawl, n8n, qdrant, scriberr, supabase)
  - [x] 1.3 Create `.gitkeep` files in all data directories to preserve structure (common/postgres_data/, common/redis_data/, etc.)
  - [x] 1.4 Remove monolithic `compose.yaml` file (will be replaced by modular service compose files)

- [x] 2.0 Create Common Infrastructure Services (PostgreSQL + Redis)
  - [x] 2.1 Create `common/docker-compose.yml` with PostgreSQL 17 and Redis Alpine services
  - [x] 2.2 Create `common/.env.example` with PostgreSQL/Redis configuration variables and detailed comments
  - [x] 2.3 Create `common/init-db.sql` script to initialize databases for firecrawl, n8n, and supabase
  - [x] 2.4 Configure PostgreSQL with proper volume mounting and restart policy
  - [x] 2.5 Configure Redis with appendonly persistence and restart policy
  - [x] 2.6 Test common services startup and verify database initialization

- [x] 3.0 Refactor Existing Services to Modular Structure
  - [x] 3.1 Create `traefik/docker-compose.yml` from existing compose.yaml traefik service
  - [x] 3.2 Create `traefik/.env.example` with optional Traefik configuration
  - [x] 3.3 Add Traefik dashboard routing with label `traefik.http.routers.api.rule=Host(\`traefik.localhost\`)`
  - [x] 3.4 Create `open-webui/docker-compose.yml` from existing compose.yaml open-webui service
  - [x] 3.5 Create `open-webui/.env.example` with Ollama, SearXNG, and Qdrant RAG configuration
  - [x] 3.6 Update Open WebUI environment variables to reference .env file
  - [x] 3.7 Create `searxng/docker-compose.yml` from existing compose.yaml searxng service
  - [x] 3.8 Create `searxng/.env.example` with secret key configuration (GENERATE_RANDOM_32 placeholder)
  - [x] 3.9 Update searxng settings.yml to reference .env secret key
  - [x] 3.10 Test refactored services with `docker compose -f traefik/docker-compose.yml up` pattern

- [x] 4.0 Create Web Crawling and Document Processing Services
  - [x] 4.1 Create `crawl4ai/Dockerfile` with Xvfb and headless browser dependencies
  - [x] 4.2 Create `crawl4ai/docker-compose.yml` with build context, Ollama integration, and display environment
  - [x] 4.3 Create `crawl4ai/.env.example` with LLM_PROVIDER, OLLAMA_BASE_URL, and optional proxy settings
  - [x] 4.4 Configure Crawl4ai Traefik labels for `crawl4ai.localhost` domain
  - [x] 4.5 Create `docling/docker-compose.yml` with docling-serve image and UI enabled
  - [x] 4.6 Create `docling/.env.example` with service configuration
  - [x] 4.7 Configure Docling Traefik labels for `docling.localhost` domain
  - [x] 4.8 Create `firecrawl/docker-compose.yml` with Playwright service and API service
  - [x] 4.9 Create `firecrawl/.env.example` with PostgreSQL, Redis, Ollama, and SearXNG integration
  - [x] 4.10 Configure Firecrawl database connection to common-postgres with firecrawl database
  - [x] 4.11 Configure Firecrawl Redis connection to common-redis
  - [x] 4.12 Configure Firecrawl Traefik labels for `firecrawl.localhost` domain
  - [x] 4.13 Test Crawl4ai, Docling, and Firecrawl services with Ollama integration

- [x] 5.0 Create Workflow Automation and AI Services
  - [x] 5.1 Create `n8n/docker-compose.yml` with main n8n service and n8n-worker service
  - [x] 5.2 Create `n8n/.env.example` with PostgreSQL, Redis, Ollama, webhook URL, and worker configuration
  - [x] 5.3 Configure n8n database connection to common-postgres with n8n database
  - [x] 5.4 Configure n8n Redis connection to common-redis for queue management
  - [x] 5.5 Enable n8n community packages and AI tool usage (N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true)
  - [x] 5.6 Disable n8n authentication for local-only setup
  - [x] 5.7 Configure n8n webhook URL as http://n8n.localhost
  - [x] 5.8 Configure n8n worker with same database/Redis connections
  - [x] 5.9 Configure n8n Traefik labels for `n8n.localhost` domain
  - [x] 5.10 Test n8n and worker services with PostgreSQL and Redis connections

- [x] 6.0 Create Vector Database and Transcription Services
  - [x] 6.1 Create `qdrant/docker-compose.yml` with Qdrant image and storage persistence
  - [x] 6.2 Create `qdrant/.env.example` with optional configuration
  - [x] 6.3 Configure Qdrant Traefik labels for `qdrant.localhost` domain (REST API and Web UI)
  - [x] 6.4 Create `scriberr/docker-compose.yml` with Scriberr image (remove NVIDIA runtime for macOS)
  - [x] 6.5 Create `scriberr/.env.example` with configuration options
  - [x] 6.6 Configure Scriberr for CPU-based transcription without GPU dependencies
  - [x] 6.7 Configure Scriberr Traefik labels for `scriberr.localhost` domain
  - [x] 6.8 Test Qdrant API access and web UI
  - [x] 6.9 Test Scriberr transcription functionality

- [ ] 7.0 Create Supabase Backend Platform
  - [ ] 7.1 Create `supabase/docker-compose.yml` with Studio, Kong, GoTrue, PostgREST, Storage, and Realtime services
  - [ ] 7.2 Create `supabase/.env.example` with JWT secrets, database connection, and local-only configuration
  - [ ] 7.3 Configure Supabase to use common-postgres with supabase database (or internal Postgres if needed)
  - [ ] 7.4 Generate JWT_SECRET and ANON_KEY placeholders (GENERATE_RANDOM_32 format)
  - [ ] 7.5 Disable Supabase authentication emails for local-only mode
  - [ ] 7.6 Configure Supabase Studio Traefik labels for `supabase.localhost` domain
  - [ ] 7.7 Test Supabase Studio access and API functionality

- [ ] 8.0 Develop Setup Script with Configuration Workflow
  - [ ] 8.1 Create `setup.sh` with shebang and basic script structure
  - [ ] 8.2 Add welcome message displaying project overview and features
  - [ ] 8.3 Implement prerequisite checks for macOS, Homebrew, Docker Desktop, and Ollama
  - [ ] 8.4 Add helpful error messages with installation instructions if prerequisites are missing
  - [ ] 8.5 Create function to generate random secrets (32-character hex strings)
  - [ ] 8.6 Implement directory creation for all service data directories
  - [ ] 8.7 Implement .env.example to .env copy logic for all services
  - [ ] 8.8 Implement secret generation and .env file population (PostgreSQL password, JWT secrets, etc.)
  - [ ] 8.9 Generate `SECRETS.md` file with all auto-generated passwords and tokens
  - [ ] 8.10 Add user pause with message: "Environment files have been created. Please review and update the .env files in each service directory with your custom configuration (API keys, external services, etc.). Press Enter when ready to continue..."
  - [ ] 8.11 Implement Docker network creation (`docker network create traefik`)
  - [ ] 8.12 Start infrastructure services (traefik, common) with `docker compose -f` commands
  - [ ] 8.13 Wait for PostgreSQL readiness and run init-db.sql to create service databases
  - [ ] 8.14 Start application services in logical order (open-webui, searxng, crawl4ai, docling, firecrawl, n8n, qdrant, scriberr, supabase)
  - [ ] 8.15 Pull Ollama models (gpt-oss:8b, llama3.1:8b, nomic-embed-text) with progress messages
  - [ ] 8.16 Display success message with all service URLs (chat.localhost, traefik.localhost, etc.)
  - [ ] 8.17 Display location of SECRETS.md file for reference
  - [ ] 8.18 Add error handling throughout script with helpful messages
  - [ ] 8.19 Make script idempotent (safe to run multiple times)
  - [ ] 8.20 Set execute permissions on setup.sh (`chmod +x setup.sh`)

- [ ] 9.0 Create Comprehensive Documentation
  - [ ] 9.1 Update README.md with Quick Start section at top (prerequisites, `./setup.sh` command, .env pause note)
  - [ ] 9.2 Add Project Overview section with architecture description and text-based diagram
  - [ ] 9.3 Create Services Guide section with all 12 services (description, URL, use cases, integrations)
  - [ ] 9.4 Add Prerequisites Details section (Homebrew, Docker Desktop, Ollama installation guides)
  - [ ] 9.5 Add Configuration section explaining .env files, auto-generated vs user-configured variables
  - [ ] 9.6 Document where to find generated secrets (SECRETS.md file location)
  - [ ] 9.7 Add Manual Setup section with step-by-step docker compose commands (optional for advanced users)
  - [ ] 9.8 Add Troubleshooting section (Docker network issues, Ollama connection problems, service-specific issues)
  - [ ] 9.9 Add Integration Examples (Qdrant with Open WebUI for RAG, n8n workflows with Ollama, web crawling)
  - [ ] 9.10 Add Development section (how to add services, modify existing services, enabling/disabling services)
  - [ ] 9.11 Add inline comments to all docker-compose.yml files explaining environment variables and configurations
  - [ ] 9.12 Verify all .env.example files have detailed comments with REQUIRED/AUTO-GENERATED/OPTIONAL markers
