# n8n Workflow Setup Guide

This guide helps you get started with n8n workflows in your local AI stack.

## Quick Start

### 1. Access n8n

1. Open http://n8n.localhost in your browser
2. Create your owner account (first-time setup)
3. You'll be taken to the n8n dashboard

### 2. Import the Example Workflow

**Option A: Via UI (Easiest)**

1. Click "Workflows" in the left sidebar
2. Click the "+" button and select "Import from File"
3. Navigate to `n8n/workflows/example-workflow.json`
4. Click "Import"

**Option B: Via API (Advanced)**

```bash
# First, get your n8n API key from Settings → API in the n8n UI
export N8N_API_KEY="your-api-key"

# Import the workflow
curl -X POST http://n8n.localhost/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @n8n/workflows/example-workflow.json
```

### 3. Set Up Supabase Credentials

The example workflow uses Supabase for data storage:

1. In n8n, go to **Settings** → **Credentials**
2. Click **"+ Add Credential"**
3. Search for **"Supabase"** and select it
4. Fill in the connection details:

```
Name: Supabase Local
Host: http://supabase-kong:8000
Service Role Secret: [check supabase/.env for SUPABASE_SERVICE_KEY]
```

5. Click **"Test connection"** to verify
6. Click **"Save"**

### 4. Create the Database Table

The example workflow stores results in a Supabase table. Create it:

```bash
# Connect to Supabase PostgreSQL
docker exec -it common-postgres psql -U postgres -d supabase

# Create the table
CREATE TABLE IF NOT EXISTS research_results (
  id SERIAL PRIMARY KEY,
  topic VARCHAR(255),
  summary TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

# Verify it was created
\dt

# Exit
\q
```

### 5. Verify Ollama Model

The workflow uses Ollama for AI processing. Make sure you have a model:

```bash
# Check available models
ollama list

# Pull a model if needed
ollama pull llama3.1:8b
```

### 6. Run the Example Workflow

1. Open the imported workflow in n8n
2. Click the **"Execute Workflow"** button (play icon)
3. Watch the nodes execute and turn green
4. Click on each node to see its output
5. Check the Supabase table for stored results:

```bash
docker exec -it common-postgres psql -U postgres -d supabase -c "SELECT * FROM research_results;"
```

Or via the Supabase REST API:
```bash
curl http://supabase.localhost/rest/v1/research_results \
  -H "apikey: [your-service-key]" \
  -H "Authorization: Bearer [your-service-key]"
```

## Understanding the Example Workflow

The example demonstrates a simple AI research pipeline:

```
Manual Trigger
    ↓
SearXNG Search (web search for "artificial intelligence")
    ↓
    ├─→ Ollama AI Summary (summarize results)
    │       ↓
    │   Save to Supabase (store via PostgREST API)
    │
    └─→ Check Qdrant Collections (parallel check)
            ↓
        Check NocoDB Projects (verify connectivity)
```

### Key Features

- **Parallel Execution**: Some nodes run simultaneously
- **Service Integration**: Connects to multiple stack services
- **Error Handling**: Includes basic error handling
- **Real-world Use**: Demonstrates practical automation

## Customizing the Workflow

### Change the Search Query

1. Click on the **"SearXNG Search"** node
2. In the parameters, find the **"q"** query parameter
3. Change `"artificial intelligence"` to your search term
4. Save and re-run

### Use Different AI Models

1. Click on the **"Ollama AI Summary"** node
2. Change the **"model"** parameter to:
   - `llama3.1:8b` - Fast and efficient (default)
   - `gpt-oss:latest` - Higher quality (if installed)
   - Any other model you've pulled with `ollama pull`

### Add More Nodes

Drag and drop from the node menu on the left:

- **HTTP Request**: Call any API (Firecrawl, Crawl4ai, Docling, etc.)
- **Code**: Write custom JavaScript/Python
- **Schedule Trigger**: Run workflows automatically
- **Webhook**: Trigger via HTTP requests
- **Database nodes**: PostgreSQL, Supabase, etc.

## Advanced Examples

### Example 1: Web Scraping Pipeline

```
Webhook Trigger
    ↓
SearXNG Search
    ↓
Loop through results
    ↓
Firecrawl (scrape each page)
    ↓
Ollama (extract key information)
    ↓
Qdrant (store embeddings)
    ↓
NocoDB (save structured data)
```

### Example 2: Document Processing

```
Manual Trigger / File Upload
    ↓
Docling (convert PDF to text)
    ↓
Split into chunks
    ↓
Ollama (generate embeddings)
    ↓
Qdrant (store vectors)
    ↓
PostgreSQL (store metadata)
```

### Example 3: Scheduled Research

```
Schedule Trigger (daily at 9am)
    ↓
SearXNG (search for trending topics)
    ↓
Filter top 5 results
    ↓
Crawl4ai (scrape with AI)
    ↓
Ollama (summarize findings)
    ↓
NocoDB (update dashboard)
    ↓
[Optional] Send notification
```

## Connecting to All Stack Services

Here's how to connect to each service in your workflows:

### SearXNG (Web Search)
```
HTTP Request Node
URL: http://searxng:8080/search
Method: GET
Query Parameters:
  q: your search query
  format: json
```

### Firecrawl (Web Scraping)
```
HTTP Request Node
URL: http://firecrawl-api:3002/v0/scrape
Method: POST
Body:
  url: webpage to scrape
```

### Crawl4ai (AI Web Crawler)
```
HTTP Request Node
URL: http://crawl4ai:11235/crawl
Method: POST
Body:
  url: webpage to crawl
```

### Docling (Document Processing)
```
HTTP Request Node
URL: http://docling:5000/api/convert
Method: POST
Body: multipart/form-data with PDF file
```

### Ollama (AI Models)
```
HTTP Request Node
URL: http://host.docker.internal:11434/api/generate
Method: POST
Body:
  model: llama3.1:8b
  prompt: your prompt
  stream: false
```

### Qdrant (Vector Database)
```
HTTP Request Node
URL: http://qdrant:6333/collections/{collection}/points
Method: POST/GET
```

### NocoDB (No-Code Database)
```
HTTP Request Node
URL: http://nocodb:8080/api/v1/db/data/v1/{base}/{table}
Method: GET/POST
Headers:
  xc-token: your NocoDB API token
```

### Supabase (Backend with REST API)
```
HTTP Request Node
URL: http://supabase-rest:3000/{table_name}
Method: GET/POST/PATCH/DELETE
Headers:
  apikey: [from supabase/.env - SUPABASE_SERVICE_KEY]
  Authorization: Bearer [same service key]
```

Or use the Supabase credential:
```
Supabase Node (if available in your n8n version)
Host: http://supabase-kong:8000
Service Role Key: [from supabase/.env]
```

### PostgreSQL (Direct Database)
```
PostgreSQL Node
Host: common-postgres
Port: 5432
Database: supabase (or nocodb, or your database)
User: postgres
Password: [from common/.env]
```

## Tips and Best Practices

1. **Test nodes individually**: Use "Execute Node" to test each step
2. **Use expressions**: Reference previous node data with `{{ $json.field }}`
3. **Enable error workflows**: Set up error handling for production
4. **Monitor execution logs**: Check workflow executions in the history
5. **Use credentials**: Store API keys and passwords securely
6. **Version control**: Export workflows regularly as backup
7. **Document custom workflows**: Add notes to nodes explaining their purpose

## Troubleshooting

### "Cannot connect to host.docker.internal"

Ollama runs on the host machine. Make sure:
1. Ollama is running: `ollama list`
2. Docker has host network access
3. Use `host.docker.internal:11434` not `localhost:11434`

### "Credential not found"

1. Go to Settings → Credentials
2. Verify the credential name matches what the workflow expects
3. Test the credential connection

### "Workflow execution failed"

1. Click on the failed node (red)
2. Check the error message in the output panel
3. Verify the service is running: `docker ps`
4. Check service logs: `docker logs <container-name>`

## Resources

- **n8n Documentation**: https://docs.n8n.io/
- **Workflow Examples**: Check `n8n/workflows/` directory
- **Community Forum**: https://community.n8n.io/
- **Video Tutorials**: https://www.youtube.com/@n8n-io

## Next Steps

1. ✅ Import the example workflow
2. ✅ Set up PostgreSQL credentials
3. ✅ Run the example successfully
4. 🎯 Modify the workflow to suit your needs
5. 🎯 Create your own workflows
6. 🎯 Share your workflows with the community!
