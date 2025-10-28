# PRD: Expanded macOS-AI Services Stack

## Introduction/Overview

This feature expands the existing macOS-AI local setup from a simple chat interface (Open WebUI + SearXNG + Ollama) into a comprehensive AI development and automation platform. The expanded stack will include web crawling, document processing, workflow automation, vector storage, transcription, and infrastructure services—all running locally on macOS with Apple Silicon GPU acceleration via Ollama.

The goal is to create a modular, well-documented, novice-friendly AI toolkit that integrates seamlessly with local Ollama models, maintains the simplicity of local-only access via Traefik domains, and includes a bash setup script for one-command deployment.

### Problem Statement
Currently, the macOS-AI project only provides basic chat functionality. Users working on AI projects need additional tools for web scraping, document processing, workflow automation, vector embeddings, and transcription—all integrated with local LLMs. Setting up these services individually is complex and time-consuming.

### Goals
1. Expand the macOS-AI stack with 9 additional services while maintaining the existing simplicity
2. Provide modular Docker Compose configuration (one file per service) for easy customization
3. Integrate all AI-capable services with local Ollama installation
4. Create a comprehensive setup script that handles all prerequisites and configuration
5. Ensure all services are accessible via intuitive Traefik `.localhost` domains
6. Provide clear, novice-friendly documentation in a single README

## User Stories

1. **As a developer**, I want to run a complete AI development stack locally so that I can build AI applications without cloud dependencies or API costs.

2. **As a novice user**, I want a simple setup process that pauses to let me review configuration files so that I can add my optional API keys before services start.

3. **As an AI researcher**, I want web crawling and document processing tools integrated with my local LLMs so that I can process and analyze content locally.

4. **As an automation enthusiast**, I want n8n workflow automation with Ollama integration so that I can create AI-powered workflows without coding.

5. **As a data scientist**, I want a local vector database (Qdrant) connected to Ollama embeddings so that I can build RAG applications locally.

6. **As a content creator**, I want automated transcription (Scriberr) so that I can process audio/video content locally.

7. **As a power user**, I want modular service configurations so that I can enable/disable services without affecting others.

8. **As a macOS user**, I want the stack to leverage Apple Silicon GPU acceleration so that I get optimal LLM performance.

9. **As a security-conscious user**, I want my secrets and API keys stored in .env files that are gitignored so that I don't accidentally commit sensitive information to version control.

10. **As a power user**, I want well-documented .env.example files so that I understand what each configuration option does and can customize services to my needs.

## Functional Requirements

### 1. Service Architecture

#### 1.1 New Services to Add
- **Crawl4ai** - AI-powered web crawler with Ollama integration
- **Docling** - Document processing and conversion service
- **Firecrawl** - Web scraping API with Playwright support
- **n8n** - Workflow automation platform with worker architecture
- **Qdrant** - Vector database for embeddings
- **Scriberr** - Audio/video transcription service
- **Supabase** - Self-hosted backend platform (separate from shared PostgreSQL)
- **PostgreSQL** - Shared database service for Firecrawl, n8n, Supabase
- **Redis** - Shared cache/queue service for Firecrawl, n8n

#### 1.2 Existing Services to Optimize
- **SearXNG** - Ensure optimal configuration and integration
- **Open WebUI** - Update configuration to integrate with new services
- **Traefik** - Expand routing configuration for all new services

### 2. Docker Compose Structure

#### 2.1 Modular Organization
- Each service must have its own `docker-compose.yml` file in a dedicated subdirectory
- Each service with configuration needs must have `.env.example` and `.env` files
- Directory structure:
  ```
  macOS-AI/
  ├── common/              # PostgreSQL + Redis
  │   ├── docker-compose.yml
  │   ├── .env.example
  │   └── .env (gitignored)
  ├── traefik/             # Reverse proxy
  │   ├── docker-compose.yml
  │   └── .env.example
  ├── open-webui/          # Chat interface
  │   ├── docker-compose.yml
  │   ├── .env.example
  │   └── data/ (gitignored)
  ├── searxng/             # Search engine
  ├── crawl4ai/            # Web crawler
  ├── docling/             # Document processor
  ├── firecrawl/           # Web scraper
  │   ├── docker-compose.yml
  │   ├── .env.example
  │   └── .env (gitignored)
  ├── n8n/                 # Workflow automation
  │   ├── docker-compose.yml
  │   ├── .env.example
  │   └── .env (gitignored)
  ├── qdrant/              # Vector database
  ├── scriberr/            # Transcription
  ├── supabase/            # Backend platform
  │   ├── docker-compose.yml
  │   ├── .env.example
  │   └── .env (gitignored)
  ├── setup.sh             # Installation script
  ├── SECRETS.md           # Generated secrets reference (gitignored)
  ├── README.md
  └── .gitignore           # Updated with comprehensive rules
  ```

#### 2.2 Service Data Persistence
- Each service stores data in its own subdirectory (e.g., `./n8n/data/`, `./qdrant/storage/`)
- Shared services (PostgreSQL, Redis) store data in `./common/`

#### 2.3 Network Configuration
- All services must connect to a shared Docker network named `traefik`
- The network must be created externally before starting services

### 3. Traefik Domain Configuration

#### 3.1 Domain Naming Convention
All services accessible via `servicename.localhost` pattern:
- `chat.localhost` - Open WebUI (existing)
- `searxng.localhost` - SearXNG (existing)
- `traefik.localhost` - Traefik dashboard
- `crawl4ai.localhost` - Crawl4ai web interface
- `docling.localhost` - Docling API/UI
- `firecrawl.localhost` - Firecrawl API
- `n8n.localhost` - n8n workflow automation
- `qdrant.localhost` - Qdrant dashboard
- `scriberr.localhost` - Scriberr web interface
- `supabase.localhost` - Supabase studio

#### 3.2 No External Access
- All services are local-only (no external DNS, no hosts file modifications)
- No port exposure except Traefik on port 80/8080
- Services communicate internally via Docker network

### 4. Ollama Integration

#### 4.1 Host-Based Ollama
- Ollama runs on macOS host (not in Docker) to access Apple Silicon GPU
- Docker services connect via `host.docker.internal:11434`

#### 4.2 Services with Ollama Integration
The following services must be pre-configured to use Ollama:
- **Crawl4ai** - LLM provider for content extraction
- **Firecrawl** - Optional LLM for JSON formatting
- **n8n** - AI nodes and LLM integrations
- **Open WebUI** - Primary chat interface (existing)

#### 4.3 Required Ollama Models
The setup script must pull these models:
1. `gpt-oss:8b` - Primary reasoning model
2. `llama3.1:8b` - Alternative LLM option
3. `nomic-embed-text` - Embedding model for Qdrant/RAG

### 5. Database Configuration

#### 5.1 Shared PostgreSQL Service
- Run PostgreSQL 17 in `common/` directory
- Create separate databases for each service:
  - `firecrawl` - Firecrawl API database
  - `n8n` - n8n workflow database
  - `supabase` - Supabase backend (or use Supabase's internal Postgres)

#### 5.2 Shared Redis Service
- Run Redis Alpine in `common/` directory
- Used by: Firecrawl (cache), n8n (queue)

#### 5.3 Service-Specific Storage
- **Qdrant** - Uses internal storage (no PostgreSQL needed)
- **Scriberr** - Uses SQLite internally
- **Docling** - Stateless (no database)
- **Crawl4ai** - Uses local file storage

### 6. Environment Variables & Secrets

#### 6.1 Environment File Structure
Each service directory must contain:
- `.env.example` - Template file with all configuration variables, documentation, and placeholder values
- `.env` - User-configured file (copied from `.env.example` by setup script, gitignored)

#### 6.2 Environment File Workflow
The setup script must:
1. Copy each `.env.example` to `.env` for all services
2. Pre-populate auto-generated values (secrets, passwords) in the `.env` files
3. **Pause execution** and display message: "Environment files have been created. Please review and update the .env files in each service directory with your custom configuration (API keys, external services, etc.). Press Enter when ready to continue..."
4. Wait for user confirmation (Enter key) before proceeding
5. After user confirmation, continue with Docker network creation and service startup

This allows users to:
- Add optional API keys (OpenAI, Anthropic, etc.)
- Configure external proxy settings
- Customize service-specific settings
- Review auto-generated secrets before services start

#### 6.3 Secret Generation
The setup script must generate random secrets and populate `.env` files with:
- PostgreSQL password (`POSTGRES_PASSWORD`)
- Redis password (if enabled)
- JWT secrets for services that need them (Supabase, n8n)
- SearXNG secret key
- Any other service-specific random tokens

#### 6.4 Secret Documentation
Document secret locations in:
- Each service's `.env` file (primary location with inline comments)
- A generated `SECRETS.md` file in project root (backup reference, gitignored)

### 7. Setup Script (setup.sh)

#### 7.1 Prerequisites Check
The script must check for:
1. macOS operating system
2. Homebrew installation
3. Docker Desktop installation and running
4. Ollama installation via Homebrew

If prerequisites are missing, provide clear installation instructions.

#### 7.2 Script Operations (in order)
1. **Display welcome message** with project overview
2. **Check prerequisites** and exit with instructions if missing
3. **Create directories** for all services (data directories, config directories)
4. **Copy `.env.example` to `.env`** for each service
5. **Generate random secrets** and populate them into `.env` files
6. **Pause for user configuration** - Display message and wait for user to review/update .env files
7. **Create Docker network** (`traefik`)
8. **Start infrastructure services** (Traefik, PostgreSQL, Redis)
9. **Initialize databases** (create named databases in PostgreSQL)
10. **Start application services** (all others)
11. **Pull Ollama models** (gpt-oss:8b, llama3.1:8b, nomic-embed-text)
12. **Display success message** with access URLs and location of secrets

#### 7.3 Script Output Requirements
- Clear progress indicators for each step
- Informative messages (e.g., "Pulling Ollama models... this may take several minutes")
- Final summary with all service URLs
- Error handling with helpful messages

#### 7.4 Interactive Elements
- **Single user prompt**: Script pauses after creating .env files to allow user configuration
- User presses Enter to continue after reviewing/updating .env files
- No other interactive prompts or complex user input required
- Script should be idempotent (safe to run multiple times)

### 8. Service-Specific Requirements

#### 8.1 n8n Configuration
- Enable PostgreSQL storage (not SQLite)
- Configure Redis for queue management
- Set up n8n worker container for background job processing
- Enable community packages and AI tool usage
- Set webhook URL to `https://n8n.localhost`
- Disable authentication (local-only)

#### 8.2 Firecrawl Configuration
- Connect to shared PostgreSQL and Redis
- Integrate Playwright service for JavaScript rendering
- Configure Ollama for LLM extraction features
- Connect to SearXNG for search capabilities

#### 8.3 Crawl4ai Configuration
- Build custom image with Xvfb (virtual display)
- Configure Ollama connection for AI extraction
- Set display environment for headless browser

#### 8.4 Scriberr Configuration
- Remove NVIDIA runtime requirements (not available on macOS)
- Configure for CPU-based transcription or Ollama integration if possible

#### 8.5 Supabase Configuration
- Deploy full Supabase stack (Studio, Kong, GoTrue, PostgREST, Storage, Realtime)
- Use separate PostgreSQL database or Supabase's internal Postgres
- Disable authentication emails (local-only mode)
- Generate secure JWT secrets

#### 8.6 Qdrant Configuration
- Expose REST API and web UI
- Configure storage persistence
- Ready for integration with nomic-embed-text model

#### 8.7 Open WebUI Updates
- Add connections to new services (Qdrant for RAG, etc.)
- Maintain existing Ollama and SearXNG integration
- Keep authentication disabled

### 9. Documentation Requirements

#### 9.1 README Structure
The README must contain:
1. **Quick Start** (top of file)
   - Prerequisites list
   - Setup command: `./setup.sh`
   - Note about pausing for .env configuration
   - Access URLs after completion
2. **Project Overview**
   - What the stack provides
   - Architecture diagram (text-based)
3. **Services Guide**
   - Brief description of each service
   - Access URL
   - Primary use cases
   - Integration points with other services
4. **Prerequisites Details**
   - Homebrew installation
   - Docker Desktop installation
   - Ollama installation
   - System requirements (Apple Silicon Mac)
5. **Manual Setup** (optional alternative to script)
   - Step-by-step Docker commands
   - For users who want to understand each step
6. **Configuration**
   - Environment variables explained
   - How .env files work and where they're located
   - Which variables are auto-generated vs user-configured
   - How to customize services
   - Enabling/disabling services
   - Where to find generated secrets (SECRETS.md)
7. **Troubleshooting**
   - Common issues and solutions
   - Docker network problems
   - Ollama connection issues
   - Service-specific troubleshooting
8. **Integration Examples**
   - Using Qdrant with Open WebUI for RAG
   - Creating n8n workflows with Ollama
   - Web crawling with Crawl4ai/Firecrawl
9. **Development**
   - How to add new services
   - Modifying existing services
   - Contributing guidelines

#### 9.2 Code Comments
- Each `docker-compose.yml` should have inline comments explaining:
  - Environment variable purposes
  - Integration points
  - Why specific configurations are needed

#### 9.3 .env.example Files
Each service's `.env.example` must:
- Include detailed comments for every environment variable
- Explain what each variable does and why it's needed
- Provide example values or placeholder formats
- Clearly mark which variables are:
  - **Required** - Must be configured for service to work
  - **Auto-generated** - Will be populated by setup script
  - **Optional** - For advanced features or external integrations
- Group related variables with section headers
- Include links to external documentation where relevant

Example structure:
```bash
# =============================================================================
# Service Name Configuration
# =============================================================================

# Database Connection (REQUIRED - Auto-generated by setup script)
POSTGRES_PASSWORD=GENERATE_RANDOM_32

# Ollama Integration (REQUIRED - Pre-configured for local setup)
OLLAMA_BASE_URL=http://host.docker.internal:11434

# External API Keys (OPTIONAL - Only needed for specific features)
# OPENAI_API_KEY=sk-your-key-here
# ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### 10. Git Configuration

#### 10.1 .gitignore Requirements
The `.gitignore` file must be updated to ignore:

**Environment & Secrets:**
- `**/.env` - All .env files in any service directory
- `SECRETS.md` - Generated secrets documentation
- `*.env` - Any other environment file variations

**Service Data Directories:**
- `common/postgres_data/` - PostgreSQL data
- `common/redis_data/` - Redis data
- `open-webui/data/` - Open WebUI data (keep existing pattern)
- `searxng/settings.yml` should remain tracked (configuration file, not data)
- `crawl4ai/data/` - Crawl4ai cache and data
- `crawl4ai/shm/` - Shared memory files
- `docling/data/` - Docling temporary files
- `firecrawl/data/` - Firecrawl storage
- `n8n/data/` - n8n workflows and database
- `qdrant/storage/` - Qdrant vector database
- `scriberr/data/` - Scriberr transcriptions
- `supabase/data/` - Supabase volumes

**Build & Runtime Files:**
- `*.log` - Log files
- `logs/` - Log directories
- `.DS_Store` - macOS system files
- `docker-compose.override.yml` - User-specific overrides

**Preserve Directory Structure:**
- Each data directory should contain a `.gitkeep` file to preserve the directory structure
- Example: `common/postgres_data/.gitkeep`, `n8n/data/.gitkeep`

#### 10.2 Repository Structure
Keep in git:
- All `docker-compose.yml` files
- All `.env.example` files (with full documentation)
- `setup.sh` script (with execute permissions)
- `README.md` (comprehensive documentation)
- `.gitkeep` files in all data directories
- Service configuration templates (like `searxng/settings.yml.example` if needed)
- `.gitignore` (comprehensive ignore rules)

## Non-Goals (Out of Scope)

1. **External Access** - No remote access, reverse tunnels, or public domains
2. **Authentication** - No password protection (local-only security model)
3. **GPU Support in Docker** - Ollama runs on host for GPU access; Docker services are CPU-only
4. **Windows/Linux Support** - Designed specifically for macOS with Apple Silicon
5. **Automatic Updates** - Users manually update services via Docker pulls
6. **Service Monitoring** - No health checks, uptime monitoring, or alerting
7. **Backup/Restore** - Users manage their own data backups
8. **Production Deployment** - This is a development/local environment only
9. **Interactive Setup** - Script runs without user prompts
10. **Postiz Integration** - Removed due to external authentication requirements

## Design Considerations

### UI/UX
- Traefik dashboard provides visual overview of all services
- Each service maintains its own native UI/UX
- Consistent `.localhost` domain pattern for easy memorization
- No browser security warnings (valid local domains)

### Service Discovery
- Traefik dashboard shows all active services and routes
- README contains comprehensive service directory
- Setup script outputs all URLs at completion

### Error Handling
- Setup script exits with clear error messages
- Services have restart policies (unless-stopped)
- Docker Compose dependency ordering prevents startup issues

## Technical Considerations

### Dependencies
- Existing Ollama installation must be running on host
- Docker network must be created before any services start
- PostgreSQL must be ready before dependent services start
- Redis must be ready before Firecrawl/n8n start

### Performance
- n8n worker architecture handles heavy workflows
- Redis caching improves Firecrawl performance
- Ollama on host provides optimal GPU acceleration
- Shared PostgreSQL reduces resource usage vs per-service databases

### Compatibility
- All services tested on macOS Sonoma 14.x with Apple Silicon
- Docker Compose v2 format
- Traefik v3.1 configuration syntax

### Port Allocation
- Only Traefik exposes ports (80, 8080)
- Internal services communicate via Docker network
- No port conflicts with existing macOS services

### Resource Management
- Services use `unless-stopped` restart policy
- No resource limits defined (assumes adequate Mac resources)
- Users can stop individual services to save resources

## Success Metrics

1. **Setup Time** - Complete stack deployment in under 30 minutes (including Ollama model downloads and user .env review)
2. **Novice Success Rate** - User with basic terminal knowledge can complete setup following README only
3. **Service Availability** - All services accessible via Traefik domains after setup
4. **Ollama Integration** - All AI-capable services successfully connect to host Ollama
5. **Documentation Clarity** - README answers 90%+ of common questions without external research
6. **Modular Design** - Users can disable individual services by commenting out compose files
7. **Setup Script Reliability** - Script runs successfully without errors on fresh macOS installation
8. **Configuration Clarity** - Users understand which .env variables need attention during setup pause
9. **Security Compliance** - No secrets or .env files accidentally committed to git

## Open Questions

1. **Supabase Complexity** - Should we include full Supabase stack or just essential components? (Studio, API, Auth)
2. **Model Selection** - Is `nomic-embed-text` still the best embedding model, or should we use a newer alternative?
3. **Scriberr GPU** - How should Scriberr work without NVIDIA GPU? CPU-based Whisper or Ollama integration?
4. **Service Limits** - Should we document recommended Mac specs (RAM, disk space) for running all services?
5. **Database Initialization** - Should PostgreSQL databases be created automatically by script or via init SQL files?
6. **Crawl4ai Build** - Should we pre-build and host the Crawl4ai image, or have users build it locally?
7. **Update Strategy** - Should we include an update script to pull latest images?

## Implementation Notes

### Reference Patterns
The implementation should follow patterns from the existing homelab Ansible templates at:
`/Users/mpruitt/projects/homelab/roles/stack/templates/`

These templates provide proven configurations for:
- Service networking
- Environment variable structure
- Volume mounting patterns
- Traefik label syntax
- Integration patterns between services

### Testing Checklist
Before considering this feature complete:
- [ ] All services start without errors
- [ ] All `.localhost` domains resolve and load
- [ ] `.env.example` files exist for all services with configuration needs
- [ ] Setup script successfully copies `.env.example` to `.env` for all services
- [ ] Setup script generates random secrets and populates .env files correctly
- [ ] Setup script pauses with clear message for user .env review
- [ ] `.gitignore` properly excludes all .env files and SECRETS.md
- [ ] Generated SECRETS.md contains all auto-generated passwords and tokens
- [ ] Ollama integration works in Crawl4ai, Firecrawl, n8n
- [ ] PostgreSQL databases created for all dependent services
- [ ] Redis connections work for Firecrawl and n8n
- [ ] n8n worker processes background jobs
- [ ] Qdrant accepts vectors from nomic-embed-text
- [ ] SearXNG integration still works with Open WebUI
- [ ] Setup script completes successfully on fresh Mac
- [ ] All documentation is clear and accurate
- [ ] No .env files or secrets committed to git after test run
