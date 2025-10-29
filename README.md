# Local AI Stack for macOS

A complete local AI environment for your Mac with Apple Silicon GPU acceleration. This stack includes chat interfaces, web search, document processing, workflow automation, vector databases, and more—all running locally with a single setup script.

## Prerequisites

- A Mac with Apple Silicon (M1 -> M5)
- Homebrew
- Docker Desktop

## Instructions

### 1. Install Homebrew

First, install Homebrew by following the instructions on their [official website](https://brew.sh/).

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
### 2. Install Ollama

To have GPU acceleration, we must install Ollama locally. Docker does not have access to Apple Silicon GPUs:

```sh
brew install ollama
```

### 3. Pull a Model with Ollama

We'll use Meta's latest model Llama3.1:

```sh
ollama pull llama3.1
```

### 4. Install Docker Desktop
Download and install Docker Desktop from Docker's [official website](https://www.docker.com/products/docker-desktop/). You could install Docker in other ways but this way is the simplest.

### 5. Clone this GitHub Repository
Clone the GitHub repository for this project and change into the directory:

```sh
git clone https://github.com/mikeydiamonds/macOS-AI.git && cd macOS-AI
```

### 6. Run the Setup Script

First make the script executable:

```sh
chmod +x setup.sh
```

Now get ready to automate your world, and grab a cup of coffee, the first run takes a bit of time ( ~10 minutes ):

```sh
./setup.sh
```

### 7. Access the Applications

| Service                                                        | Local URL                            | status  | Use                           |
|----------------------------------------------------------------|--------------------------------------|---------|-------------------------------|
| [Open WebUI](https://docs.openwebui.com/)                      | http://chat.localhost                |    ✅   | AI Chat Interface             |
| [SearXNG](https://github.com/searxng/searxng)                  | http://searxng.localhost             |    ✅   | Private Web Search            |
| [Firecrawl](https://docs.firecrawl.dev/contributing/self-host) | http://firecrawl.localhost           |    ✅   | Web Scraping API              |
| [Crawl4ai](https://docs.crawl4ai.com/)                         | http://crawl4ai.localhost/playground |    ✅   | AI-Powered Web Crawler        |
| [Docling](https://www.docling.ai/)                             | http://docling.localhost/ui          |    ✅   | Document Processing           |
| [n8n](https://github.com/n8n-io/n8n)                           | http://n8n.localhost                 |    ✅   | Workflow Automation           |
| [Qdrant](https://qdrant.tech/)                                 | http://qdrant.localhost/dashboard    |    ✅   | Vector Database               |
| [Scriberr](https://github.com/rishikanthc/Scriberr)            | http://scriberr.localhost            | testing | Audio Transcription           |
| [Supabase](https://supabase.com/docs/guides/self-hosting)      | http://supabase.localhost            |    ✅   | Database & Backend            |
| [NocoDB](https://nocodb.com/)                                  | http://nocodb.localhost              |    ✅   | No-Code Database Platform     |
| [Traefik](https://traefik.io/)                                 | http://traefik.localhost             |    ✅   | Reverse Proxy & Routing       |

### 8. Get Started with n8n Workflows

We've included example workflows to help you get started with automation:

1. Access n8n at http://n8n.localhost and create your owner account
2. Follow the [n8n Workflow Setup Guide](n8n/WORKFLOWS.md) to import the example workflow
3. The example demonstrates connecting SearXNG, Ollama, Supabase, Qdrant, and NocoDB

**Quick start:**
- Example workflows: `n8n/workflows/`
- Full guide: [`n8n/WORKFLOWS.md`](n8n/WORKFLOWS.md)
- Workflow ideas: Search → Scrape → AI Analysis → Store in Database

## Troubleshooting

- **Reset the stack/start over**: `./setup.sh --reset`
  
- **Docker Desktop Issues**: Make sure Docker Desktop is running and you have granted necessary permissions. Adjust resource limits in the settings.
- **Model Pull Issues**: Ensure you have a stable internet connection while pulling the model using Ollama.
- **Network Issues**: If you can't access `http://chat.localhost`, verify your Docker network settings and ensure no other services are conflicting with port 80.

Feel free to open an issue on this GitHub repository if you encounter any problems not covered in this guide.

### And above all, have fun with local AI and automation!

Happy coding! 🚀