# Firecrawl - Web Scraping Service

## Apple Silicon / ARM64 Support

The official Firecrawl images are hosted on GitHub Container Registry (ghcr.io):
- `ghcr.io/firecrawl/firecrawl:latest`
- `ghcr.io/firecrawl/playwright-service:latest`

**Platform Compatibility**: These images are **only available for AMD64/x86_64 architecture**. On Apple Silicon Macs (M1/M2/M3), Docker Desktop automatically uses **Rosetta 2 emulation** to run these images.

### Configuration for Apple Silicon

The [docker-compose.yml](./docker-compose.yml) includes `platform: linux/amd64` directives to explicitly document this requirement and suppress Docker warnings:

```yaml
services:
  playwright:
    image: ghcr.io/firecrawl/playwright-service:latest
    platform: linux/amd64  # Images only available for AMD64 - uses Rosetta 2 on Apple Silicon

  api:
    image: ghcr.io/firecrawl/firecrawl:latest
    platform: linux/amd64  # Images only available for AMD64 - uses Rosetta 2 on Apple Silicon
```

**Note**: While the `platform` directive is optional (Docker will automatically use Rosetta 2), it's included to:
1. Suppress "platform mismatch" warnings during container creation
2. Document the architecture requirement for future reference
3. Make the emulation explicit and intentional

### Potential Issues

**"Error from registry: denied"**
This occurs if you have expired Docker credentials for ghcr.io. Solution:
```bash
docker logout ghcr.io
```

After logout, Docker will pull public images without authentication.

## Service Configuration

Once running, Firecrawl will be available at:
- **API**: http://firecrawl.localhost
- **Internal Playwright Service**: http://firecrawl-playwright:3000 (internal only)

### Features
- Web scraping with JavaScript rendering via Playwright
- PostgreSQL database for persistence
- Redis for queue management
- Ollama integration for LLM-powered extraction
- SearXNG integration for web search

### Environment Variables
See [.env.example](./.env.example) for all configuration options.
