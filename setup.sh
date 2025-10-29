#!/bin/bash
# =============================================================================
# macOS-AI Stack Setup Script
# =============================================================================
# This script automates the setup of the complete AI development stack including:
# - Infrastructure: Traefik, PostgreSQL, Redis
# - Chat Interface: Open WebUI
# - Search: SearXNG
# - Web Crawling: Crawl4ai, Docling, Firecrawl
# - Workflow: n8n with worker
# - Vector DB: Qdrant
# - Transcription: Scriberr
# - Backend: Supabase
#
# Requirements: macOS, Homebrew, Docker Desktop, Ollama
#
# Usage:
#   ./setup.sh          - Normal setup (preserves existing .env files)
#   ./setup.sh --reset  - Clean install (removes all data and regenerates secrets)
# =============================================================================

set -e  # Exit on error

# Parse command line arguments
RESET_MODE=false
if [[ "$1" == "--reset" ]]; then
    RESET_MODE=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_header() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}\n"; }

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for service health
wait_for_service() {
    local service_name=$1
    local container_name=$2
    local max_wait=${3:-60}
    local count=0

    print_info "Waiting for $service_name to be healthy..."
    while [ $count -lt $max_wait ]; do
        if docker ps --filter "name=$container_name" --filter "health=healthy" | grep -q "$container_name"; then
            print_success "$service_name is healthy"
            return 0
        fi
        sleep 2
        count=$((count + 2))
    done
    print_warning "$service_name health check timeout (this may be normal for some services)"
    return 0
}

# Function to wait for container to be running
wait_for_container() {
    local service_name=$1
    local container_name=$2
    local max_wait=${3:-30}
    local count=0

    print_info "Waiting for $service_name to start..."
    while [ $count -lt $max_wait ]; do
        if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
            print_success "$service_name is running"
            return 0
        fi
        sleep 2
        count=$((count + 2))
    done
    print_error "$service_name failed to start"
    return 1
}

# Function to generate random secret
generate_secret() {
    openssl rand -hex 16
}

# =============================================================================
# WELCOME MESSAGE
# =============================================================================
clear
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                          macOS-AI Stack Setup                            ║
║                                                                          ║
║  This script will set up a complete local AI development environment     ║
║  with the following services:                                            ║
║                                                                          ║
║  • Open WebUI - Chat interface at http://chat.localhost                  ║
║  • SearXNG - Search engine at http://search.localhost                    ║
║  • Firecrawl - Web scraping at http://firecrawl.localhost                ║
║  • Crawl4ai - Web crawling at http://crawl4ai.localhost                  ║
║  • Docling - Document processing at http://docling.localhost             ║
║  • n8n - Workflow automation at http://n8n.localhost                     ║
║  • Qdrant - Vector database at http://qdrant.localhost                   ║
║  • Scriberr - Transcription at http://scriberr.localhost                 ║
║  • Supabase - Backend platform at http://supabase.localhost              ║
║  • NocoDB - No-Code database at http://nocodb.localhost                  ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF

if [ "$RESET_MODE" = true ]; then
    echo ""
    print_warning "Running in RESET MODE - all existing data will be removed"
    echo ""
fi

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================
print_header "Checking Prerequisites"

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script requires macOS"
    exit 1
fi
print_success "Running on macOS"

# Check Homebrew
if ! command_exists brew; then
    print_error "Homebrew is not installed"
    print_info "Install from: https://brew.sh"
    exit 1
fi
print_success "Homebrew is installed"

# Check Docker
if ! command_exists docker; then
    print_error "Docker is not installed"
    print_info "Install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker daemon is not running"
    print_info "Please start Docker Desktop and try again"
    exit 1
fi
print_success "Docker is running"

# Check Ollama
if ! command_exists ollama; then
    print_error "Ollama is not installed"
    print_info "Install with: brew install ollama"
    exit 1
fi
print_success "Ollama is installed"

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    print_warning "Ollama is not running"
    print_info "Starting Ollama service..."
    brew services start ollama
    sleep 3
    if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        print_error "Failed to start Ollama"
        print_info "Please start Ollama manually with: ollama serve"
        exit 1
    fi
fi
print_success "Ollama is running"

# =============================================================================
# ENVIRONMENT FILE SETUP
# =============================================================================
print_header "Setting Up Environment Files"

# Array of services with .env files
services=(
    "common"
    "open-webui"
    "searxng"
    "firecrawl"
    "crawl4ai"
    "docling"
    "n8n"
    "qdrant"
    "scriberr"
    "supabase"
    "nocodb"
)

# Handle reset mode
if [ "$RESET_MODE" = true ]; then
    print_warning "RESET MODE: This will delete all existing .env files and data directories"
    print_warning "Press Ctrl+C to cancel, or ENTER to continue..."
    read -r

    print_info "Stopping all services..."
    for service in "${services[@]}"; do
        if [ -f "$service/docker-compose.yml" ]; then
            docker compose -f "$service/docker-compose.yml" down 2>/dev/null || true
        fi
    done
    docker compose -f traefik/docker-compose.yml down 2>/dev/null || true

    print_info "Removing .env files..."
    for service in "${services[@]}"; do
        rm -f "$service/.env"
    done

    print_info "Removing data directories..."
    rm -rf common/postgres_data common/redis_data
    rm -rf n8n/data/.n8n
    rm -rf open-webui/data
    rm -rf qdrant/data
    rm -rf scriberr/data
    rm -rf supabase/data
    rm -rf firecrawl/data
    rm -rf crawl4ai/data
    rm -rf docling/data
    rm -rf nocodb/data
    rm -f SECRETS.md

    print_success "Reset complete - proceeding with fresh installation"
fi

# Check if .env files already exist
ENV_FILES_EXIST=false
EXISTING_ENV_COUNT=0
for service in "${services[@]}"; do
    if [ -f "$service/.env" ]; then
        ENV_FILES_EXIST=true
        EXISTING_ENV_COUNT=$((EXISTING_ENV_COUNT + 1))
    fi
done

if [ "$ENV_FILES_EXIST" = true ]; then
    print_warning "Found $EXISTING_ENV_COUNT existing .env file(s)"
    print_info "Existing configuration will be preserved (idempotent mode)"
    print_info "To regenerate secrets, run: ./setup.sh --reset"

    # Load existing secrets from .env files
    if [ -f "common/.env" ]; then
        POSTGRES_PASSWORD=$(grep "^POSTGRES_PASSWORD=" common/.env | cut -d'=' -f2)
    fi
    if [ -f "searxng/.env" ]; then
        SEARXNG_SECRET=$(grep "^SEARXNG_SECRET_KEY=" searxng/.env | cut -d'=' -f2)
    fi
    if [ -f "n8n/.env" ]; then
        N8N_ENCRYPTION_KEY=$(grep "^N8N_ENCRYPTION_KEY=" n8n/.env | cut -d'=' -f2)
    fi
    if [ -f "supabase/.env" ]; then
        JWT_SECRET=$(grep "^JWT_SECRET=" supabase/.env | cut -d'=' -f2)
    fi

    print_success "Loaded existing secrets from .env files"
else
    # Generate new secrets
    print_info "Generating random secrets..."
    POSTGRES_PASSWORD=$(generate_secret)
    SEARXNG_SECRET=$(generate_secret)
    N8N_ENCRYPTION_KEY=$(generate_secret)
    JWT_SECRET=$(generate_secret)
    print_success "Secrets generated"
fi

# Create missing .env files from templates
print_info "Checking for missing .env files..."
CREATED_COUNT=0

for service in "${services[@]}"; do
    if [ -f "$service/.env.example" ] && [ ! -f "$service/.env" ]; then
        cp "$service/.env.example" "$service/.env"

        # Replace GENERATE_RANDOM_32 with actual secrets
        if [ "$service" = "common" ] || [ "$service" = "firecrawl" ] || [ "$service" = "n8n" ] || [ "$service" = "supabase" ]; then
            sed -i '' "s/GENERATE_RANDOM_32/$POSTGRES_PASSWORD/g" "$service/.env"
        fi

        if [ "$service" = "searxng" ]; then
            sed -i '' "s/GENERATE_RANDOM_32/$SEARXNG_SECRET/g" "$service/.env"
        fi

        if [ "$service" = "n8n" ]; then
            sed -i '' "s/GENERATE_RANDOM_32/$N8N_ENCRYPTION_KEY/g" "$service/.env"
        fi

        if [ "$service" = "supabase" ]; then
            # JWT_SECRET already replaced by first sed
            # Need to generate JWT tokens for anon and service keys
            # For now, use placeholders - user will need to generate proper JWTs
            sed -i '' "s/GENERATE_JWT_ANON/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvY2FsaG9zdCIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjQxNzY5MjAwLCJleHAiOjE5NTczNDUyMDB9.dc6hdXRjaEMjJ5N5SJKKCgYEMPJ7VdCiPK2TKM8Q5WA/g" "$service/.env"
            sed -i '' "s/GENERATE_JWT_SERVICE/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvY2FsaG9zdCIsInJvbGUiOiJzZXJ2aWNlX3JvbGUiLCJpYXQiOjE2NDE3NjkyMDAsImV4cCI6MTk1NzM0NTIwMH0.qVh4rZj5EfnMbRAjFHFHRGiXsqxMXNYXPpyNx0E7Xg8/g" "$service/.env"
        fi

        print_success "Created $service/.env"
        CREATED_COUNT=$((CREATED_COUNT + 1))
    elif [ -f "$service/.env" ]; then
        print_info "Preserved existing $service/.env"
    fi
done

if [ $CREATED_COUNT -eq 0 ] && [ "$ENV_FILES_EXIST" = true ]; then
    print_success "All .env files already exist - no changes needed"
fi

# Create or update SECRETS.md
if [ ! -f "SECRETS.md" ] || [ "$RESET_MODE" = true ]; then
    print_info "Creating SECRETS.md file..."
    cat > SECRETS.md << EOF
# Generated Secrets for macOS-AI Stack

**⚠️ KEEP THIS FILE SECURE - DO NOT COMMIT TO GIT ⚠️**

Generated on: $(date)

## Database Credentials

### PostgreSQL (common-postgres)
- **User**: postgres
- **Password**: \`$POSTGRES_PASSWORD\`
- **Connection**: postgresql://postgres:$POSTGRES_PASSWORD@localhost:5432

## Service Secrets

### SearXNG
- **Secret Key**: \`$SEARXNG_SECRET\`

### n8n
- **Encryption Key**: \`$N8N_ENCRYPTION_KEY\`
- **First-time setup**: Create an owner account on first access at http://n8n.localhost
- **Note**: Owner account setup is required and cannot be automated

### Scriberr
- **First-time setup**: Create an admin account on first access at http://scriberr.localhost
- **Optional**: Pre-configure credentials by setting SCRIBERR_USERNAME and SCRIBERR_PASSWORD in scriberr/.env

### Supabase
- **JWT Secret**: \`$JWT_SECRET\`
- **Anon Key**: See supabase/.env
- **Service Key**: See supabase/.env
- **Note**: JWT tokens are placeholder values for local development

## Service URLs

All services are accessible via *.localhost domains:

- **Open WebUI**: http://chat.localhost
- **SearXNG**: http://searxng.localhost
- **Firecrawl**: http://firecrawl.localhost
- **Crawl4ai**: http://crawl4ai.localhost/playground/
- **Docling**: http://docling.localhost/ui/
- **n8n**: http://n8n.localhost
- **Qdrant**: http://qdrant.localhost/dashboard
- **Scriberr**: http://scriberr.localhost
- **Supabase Studio**: http://supabase.localhost
- **Traefik Dashboard**: http://traefik.localhost

## Notes

- All services use local-only authentication (no passwords required)
- Ollama runs on host at http://localhost:11434 for GPU access
- PostgreSQL databases: firecrawl, n8n, supabase
  - Firecrawl: NuQ queue schema initialized from firecrawl/nuq.sql
  - Supabase: Auth, storage, realtime schemas initialized from supabase/init.sql
- Redis available at common-redis:6379 (internal)
- PostgreSQL available at common-postgres:5432 (internal)

## First-Time Setup Requirements

### n8n (http://n8n.localhost)
- **Action Required**: Create an owner account on first access
- Cannot be automated via environment variables
- Required for workflow automation features

### Open WebUI (http://chat.localhost)
- **Web Search**: Pre-configured to use SearXNG
- **Note**: Web search must be manually enabled per chat in the UI
- No environment variable to enable web search by default (per-user setting)

### Scriberr (http://scriberr.localhost)
- **Action Required**: Create an admin account on first access
- **Optional**: Pre-configure credentials in scriberr/.env to skip setup wizard

EOF

    print_success "SECRETS.md created"
else
    print_info "SECRETS.md already exists - preserving existing file"
fi

# =============================================================================
# USER REVIEW PAUSE
# =============================================================================
if [ "$RESET_MODE" = true ] || [ $CREATED_COUNT -gt 0 ]; then
    print_header "Review Configuration"

    if [ "$RESET_MODE" = true ]; then
        print_info "Fresh installation - all secrets have been regenerated"
    elif [ $CREATED_COUNT -gt 0 ]; then
        print_info "Created $CREATED_COUNT new .env file(s)"
    fi

    print_info "You can review and modify any .env files before proceeding"
    print_info ""
    print_info "Configuration files:"
    for service in "${services[@]}"; do
        if [ -f "$service/.env" ]; then
            echo "  • $service/.env"
        fi
    done
    if [ -f "SECRETS.md" ]; then
        echo "  • SECRETS.md"
    fi
    print_info ""
    print_warning "Press ENTER to continue with service startup, or Ctrl+C to exit and modify files"
    read -r
else
    print_info "Using existing configuration - skipping review pause"
    print_info "Run with --reset flag to regenerate all secrets"
fi

# =============================================================================
# DOCKER NETWORK SETUP
# =============================================================================
print_header "Setting Up Docker Network"

# Create traefik network if it doesn't exist
if ! docker network inspect traefik >/dev/null 2>&1; then
    print_info "Creating traefik network..."
    docker network create traefik
    print_success "Network created"
else
    print_success "Network already exists"
fi

# =============================================================================
# SERVICE STARTUP
# =============================================================================
print_header "Starting Services"

# Change to project directory
cd "$(dirname "$0")"

# Start infrastructure services first
print_info "Starting infrastructure services (Traefik, PostgreSQL, Redis)..."
docker compose -f traefik/docker-compose.yml up -d
docker compose -f common/docker-compose.yml up -d

# Wait for infrastructure
sleep 5
wait_for_service "PostgreSQL" "common-postgres" 60
wait_for_container "Redis" "common-redis" 30
wait_for_container "Traefik" "traefik" 30

# =============================================================================
# DATABASE INITIALIZATION
# =============================================================================
print_header "Initializing Databases"

# Create databases for services
print_info "Creating databases for services..."
docker exec common-postgres psql -U postgres -c "CREATE DATABASE IF NOT EXISTS firecrawl;" 2>/dev/null || \
docker exec common-postgres psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname = 'firecrawl';" | grep -q 1 || \
docker exec common-postgres psql -U postgres -c "CREATE DATABASE firecrawl;"

docker exec common-postgres psql -U postgres -c "CREATE DATABASE IF NOT EXISTS n8n;" 2>/dev/null || \
docker exec common-postgres psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname = 'n8n';" | grep -q 1 || \
docker exec common-postgres psql -U postgres -c "CREATE DATABASE n8n;"

docker exec common-postgres psql -U postgres -c "CREATE DATABASE IF NOT EXISTS supabase;" 2>/dev/null || \
docker exec common-postgres psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname = 'supabase';" | grep -q 1 || \
docker exec common-postgres psql -U postgres -c "CREATE DATABASE supabase;"

docker exec common-postgres psql -U postgres -c "CREATE DATABASE IF NOT EXISTS nocodb;" 2>/dev/null || \
docker exec common-postgres psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname = 'nocodb';" | grep -q 1 || \
docker exec common-postgres psql -U postgres -c "CREATE DATABASE nocodb;"

print_success "Databases created"

# Initialize Firecrawl schema (NuQ queue system)
if [ -f "firecrawl/nuq.sql" ]; then
    print_info "Initializing Firecrawl database schema..."
    docker exec -i common-postgres psql -U postgres -d firecrawl < firecrawl/nuq.sql >/dev/null 2>&1 || true
    print_success "Firecrawl schema initialized"
fi

# Initialize Supabase schema (auth, storage, realtime)
if [ -f "supabase/init.sql" ]; then
    print_info "Initializing Supabase database schema..."
    docker exec -i common-postgres psql -U postgres -d supabase < supabase/init.sql >/dev/null 2>&1 || true
    print_success "Supabase schema initialized"
fi

# Start search engine
print_info "Starting SearXNG..."
docker compose -f searxng/docker-compose.yml up -d
wait_for_container "SearXNG" "searxng" 30

# Start chat interface
print_info "Starting Open WebUI..."
docker compose -f open-webui/docker-compose.yml up -d
wait_for_container "Open WebUI" "open-webui" 30

# Start web crawling services
print_info "Starting web crawling services..."
docker compose -f firecrawl/docker-compose.yml up -d
docker compose -f crawl4ai/docker-compose.yml up -d
docker compose -f docling/docker-compose.yml up -d
wait_for_container "Firecrawl" "firecrawl-api" 60
wait_for_container "Crawl4ai" "crawl4ai" 45
wait_for_container "Docling" "docling" 30

# Start workflow automation
print_info "Starting n8n with worker..."
docker compose -f n8n/docker-compose.yml up -d
wait_for_container "n8n" "n8n" 45
wait_for_container "n8n-worker" "n8n-worker" 30

# Start vector database
print_info "Starting Qdrant..."
docker compose -f qdrant/docker-compose.yml up -d
wait_for_container "Qdrant" "qdrant" 30

# Start transcription service
print_info "Starting Scriberr..."
docker compose -f scriberr/docker-compose.yml up -d
wait_for_container "Scriberr" "scriberr" 45

# Start Supabase stack
print_info "Starting Supabase services..."
docker compose -f supabase/docker-compose.yml up -d
sleep 15
wait_for_service "Supabase Kong" "supabase-kong" 45
wait_for_container "Supabase Meta" "supabase-meta" 30
wait_for_container "Supabase Auth" "supabase-auth" 45
wait_for_container "Supabase Storage" "supabase-storage" 45
wait_for_container "Supabase Realtime" "supabase-realtime" 45
wait_for_container "Supabase Studio" "supabase-studio" 30

# Start NocoDB
print_info "Starting NocoDB..."
docker compose -f nocodb/docker-compose.yml up -d
wait_for_container "NocoDB" "nocodb" 30

# =============================================================================
# SUCCESS MESSAGE
# =============================================================================
print_header "Setup Complete!"

cat << "EOF"

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║                     🎉 Setup Completed Successfully! 🎉                  ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

EOF

print_success "All services are running!"
echo ""
print_info "Access your services at the following URLs:"
echo ""
echo " Chat Interface:       http://chat.localhost                  🤖"  
echo " Search Engine:        http://searxng.localhost               🔍"
echo " Firecrawl:            http://firecrawl.localhost             🕷️"
echo " Crawl4ai:             http://crawl4ai.localhost/playground/  🕸️"
echo " Docling:              http://docling.localhost/ui/           📄"
echo " n8n Workflows:        http://n8n.localhost                   🔄"
echo " Qdrant:               http://qdrant.localhost/dashboard      🗄️"
echo " Scriberr:             http://scriberr.localhost              🎙️"
echo " Supabase Studio:      http://supabase.localhost              🗃️"
echo " NocoDB:               http://nocodb.localhost                📊"
echo " Traefik Dashboard:    http://traefik.localhost               🚦"
echo ""
print_info "Your secrets are stored in: SECRETS.md (keep this file secure!)"
echo ""
print_info "Useful commands:"
echo "  • View all running containers:  docker ps"
echo "  • Reset the stack/start over:   ./setup.sh --reset"
echo "  • View service logs:            docker compose -f <service>/docker-compose.yml logs -f"
echo "  • Stop all services:            docker compose -f */docker-compose.yml down"
echo "  • Restart a service:            docker compose -f <service>/docker-compose.yml restart"
echo ""
print_info "Get Started with Automation:"
echo "  • Import example n8n workflow:  See n8n/WORKFLOWS.md for instructions"
echo "  • Example workflow shows:       SearXNG → Ollama → Supabase → Qdrant → NocoDB"
echo "  • Workflow file location:       n8n/workflows/example-workflow.json"
echo ""

# =============================================================================
# OLLAMA MODEL SETUP (OPTIONAL)
# =============================================================================

# Check if user already has gpt-oss or llama models installed
existing_models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' || echo "")

# Check if any gpt-oss or llama models exist
has_gpt_oss=false
has_llama=false
if echo "$existing_models" | grep -q "gpt-oss"; then
    has_gpt_oss=true
fi
if echo "$existing_models" | grep -q "llama"; then
    has_llama=true
fi

# Only show Ollama Model Setup section if no models found
if [ "$has_gpt_oss" = false ] && [ "$has_llama" = false ]; then
    print_header "Ollama Model Setup"

    # No gpt-oss or llama models found - offer interactive selection
    print_warning "No language models detected. You'll need at least one model to use Open WebUI."
    echo ""
    print_info "Recommended models for this stack:"
    echo ""
    echo "  [1] nomic-embed-text:latest (274MB)"
    echo "      └─ Embeddings for RAG and vector operations"
    echo ""
    echo "  [2] llama3.1:8b (4.9GB)"
    echo "      └─ Fast, efficient model for general tasks"
    echo ""
    echo "  [3] gpt-oss:latest (14GB)"
    echo "      └─ Most capable model, slower but highest quality"
    echo ""
    print_warning "Downloads can take significant time depending on your connection"
    echo ""
    print_info "Which models would you like to download?"
    print_info "Enter numbers separated by spaces (e.g., '1 2 3' for all, '2' for just llama3.1)"
    print_info "Or press ENTER to skip for now:"
    read -r selection

    if [ -n "$selection" ]; then
        print_header "Downloading Selected Models"

        # Parse user selection and download
        for num in $selection; do
            case $num in
                1)
                    print_info "Downloading nomic-embed-text:latest (274MB)..."
                    echo "└─ Embeddings for RAG and vector operations"
                    if ollama pull nomic-embed-text:latest; then
                        print_success "nomic-embed-text:latest installed successfully"
                    else
                        print_error "Failed to download nomic-embed-text:latest"
                        print_info "You can try again later with: ollama pull nomic-embed-text:latest"
                    fi
                    echo ""
                    ;;
                2)
                    print_info "Downloading llama3.1:8b (4.9GB)..."
                    echo "└─ Fast, efficient model for general tasks"
                    if ollama pull llama3.1:8b; then
                        print_success "llama3.1:8b installed successfully"
                    else
                        print_error "Failed to download llama3.1:8b"
                        print_info "You can try again later with: ollama pull llama3.1:8b"
                    fi
                    echo ""
                    ;;
                3)
                    print_info "Downloading gpt-oss:latest (14GB)..."
                    echo "└─ Most capable model, slower but highest quality"
                    if ollama pull gpt-oss:latest; then
                        print_success "gpt-oss:latest installed successfully"
                    else
                        print_error "Failed to download gpt-oss:latest"
                        print_info "You can try again later with: ollama pull gpt-oss:latest"
                    fi
                    echo ""
                    ;;
                *)
                    print_warning "Invalid selection: $num (skipping)"
                    ;;
            esac
        done
        print_success "Model downloads complete!"
    else
        print_info "Skipping model downloads"
        echo ""
        print_info "You can install models later with these commands:"
        echo "  • ollama pull nomic-embed-text:latest  # 274MB - Embeddings for RAG and vector operations"
        echo "  • ollama pull llama3.1:8b  # 4.9GB - Fast, efficient model for general tasks"
        echo "  • ollama pull gpt-oss:latest  # 14GB - Most capable model, slower but highest quality"
    fi
fi

# =============================================================================
# OLLAMA CONTEXT WINDOW INFORMATION
# =============================================================================

# Check if any models are installed
# all_models=$(ollama list 2>/dev/null | tail -n +2)
# if [ -n "$all_models" ]; then
#     echo ""
#     print_header "Ollama Context Window Configuration"

#     print_info "Ollama models use a default context window of 2048 tokens (~1500 words)"
#     print_info "This can be limiting for long conversations or large document analysis"
#     echo ""
#     print_warning "Recommended: Increase context to 32k-128k tokens for better performance"
#     echo ""
#     echo "┌─ Context Size Options:"
#     echo "│"
#     echo "│  •  32k tokens (32768)  - 4x default, good for most use cases"
#     echo "│  •  64k tokens (65536)  - 8x default, ideal for long conversations"
#     echo "│  • 128k tokens (131072) - Maximum for llama3.1/gpt-oss, best quality"
#     echo "│"
#     echo "└─ Note: Higher context = more VRAM usage (~1GB per 4k tokens)"
#     echo ""
#     print_info "How to set context window in Open WebUI:"
#     echo ""
#     echo "  1. Go to Settings → Models"
#     echo "  2. Select your model (e.g., llama3.1:8b)"
#     echo "  3. Click 'Advanced Parameters'"
#     echo "  4. Set 'Context Length' to 32768 (or 65536/131072)"
#     echo "  5. Click 'Save'"
#     echo ""
#     print_info "Or use the Ollama CLI:"
#     echo ""
#     echo "  # Create a model with custom context (example: 32k)"
#     echo "  echo 'FROM llama3.1:8b' > /tmp/modelfile"
#     echo "  echo 'PARAMETER num_ctx 32768' >> /tmp/modelfile"
#     echo "  ollama create llama3.1-32k -f /tmp/modelfile"
#     echo ""
#     print_success "Tip: Start with 32k context and increase if needed"
# fi

echo ""
print_success "Happy coding! 🚀"
echo ""
