# Local AI for macOS

This project sets up a simple local AI environment on your Mac, utilizing Apple Silicon GPUs for optimal performance. You'll use Homebrew to install Ollama, pull a model, and Docker to run the Open Web UI and SearXNG for enhanced functionality.

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

| Service                                                             | Local URL                            | Use  |
|---------------------------------------------------------------------|--------------------------------------|------|
| [Open WebUI](https://docs.openwebui.com/)                           | http://chat.localhost                |  🤖  |
| [SearXNG](https://github.com/searxng/searxng)                       | http://searxng.localhost             |  🔍  |
| [Firecrawl](https://docs.firecrawl.dev/contributing/self-host)      | http://firecrawl.localhost           |  🕷️  |
| [Crawl4ai](https://docs.crawl4ai.com/)                              | http://crawl4ai.localhost/playground |  🕸️  |
| [Docling](https://www.docling.ai/)                                  | http://docling.localhost/ui          |  📄  |
| [n8n](https://github.com/n8n-io/n8n)                                | http://n8n.localhost                 |  🔄  |
| [Qdrant](https://qdrant.tech/)                                      | http://qdrant.localhost/dashboard    |  🗄️  |
| [Scriberr](https://github.com/rishikanthc/Scriberr) (testing)       | http://scriberr.localhost            |  🎙️  |
| [Supabase](https://supabase.com/docs/guides/self-hosting) (testing) | http://supabase.localhost            |  🗃️  |
| [Traefik](https://traefik.io/)                                      | http://traefik.localhost             |  🚦  |


## Additional Information

- (**Open WebUI**)[https://docs.openwebui.com/] does have authentication built in but I have disabled the feature for this local only project. To enable, just remove `- WEBUI_AUTH=false` from `compose.yml`.
- (**Traefik**)[https://traefik.io/] is used as a reverse proxy to manage routing for the Open Web UI and SearXNG.
- (**SearXNG**)[https://github.com/searxng/searxng] is configured for web searches and integrated with the Open Web UI.

Ensure Docker Desktop is running before executing the Docker Compose command. If you encounter any issues, refer to the documentation of the respective tools or the project's GitHub issues page for troubleshooting.

## Troubleshooting

- **Reset the stack/start over**: `./setup.sh --reset`
  
- **Docker Desktop Issues**: Make sure Docker Desktop is running and you have granted necessary permissions. Adjust resource limits in the settings.
- **Model Pull Issues**: Ensure you have a stable internet connection while pulling the model using Ollama.
- **Network Issues**: If you can't access `http://chat.localhost`, verify your Docker network settings and ensure no other services are conflicting with port 80.

Feel free to open an issue on this GitHub repository if you encounter any problems not covered in this guide.

And above all, have fun with local AI and automation!
