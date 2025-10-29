# n8n Example Workflows

This directory contains example workflows demonstrating integration between services in your local AI stack.

## Available Examples

### 1. Stack Services Example (`example-workflow.json`)

A practical workflow that demonstrates how to connect multiple services:

**What it does:**
1. Uses SearXNG to search the web
2. Sends results to Ollama for AI summarization
3. Saves the summary to Supabase (via PostgREST API)
4. Queries Qdrant and NocoDB to check their status

**Services demonstrated:**
- SearXNG (web search)
- Ollama (AI processing)
- Supabase (backend/database with REST API)
- Qdrant (vector database)
- NocoDB (no-code database)

## Importing Workflows

### Automatic Import (Recommended)

The workflows are automatically imported when you run `./setup.sh` if n8n is empty.

### Manual Import

1. Access n8n at http://n8n.localhost
2. Click on "Workflows" in the left sidebar
3. Click "+ Add workflow" → "Import from file"
4. Select `example-workflow.json`
5. Click "Import"

## Setting Up Credentials

Before running the example workflow, you need to set up Supabase credentials:

### Supabase Credential

1. Go to Settings → Credentials in n8n
2. Click "+ Add Credential"
3. Search for "Supabase" and select it
4. Fill in the details:
   - **Host**: `http://supabase-kong:8000`
   - **Service Role Secret**: Check your `supabase/.env` file for `SUPABASE_SERVICE_KEY`
5. Click "Test connection" to verify
6. Save as "Supabase Local"

### Creating the Database Table

Before running the workflow, create the table in Supabase:

```sql
-- Connect to Supabase PostgreSQL
docker exec -it common-postgres psql -U postgres -d supabase

-- Create table
CREATE TABLE IF NOT EXISTS research_results (
  id SERIAL PRIMARY KEY,
  topic VARCHAR(255),
  summary TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Verify it was created
\dt

-- Exit
\q
```

## Customizing the Workflow

### Change the Search Query

Edit the "SearXNG Search" node and modify the `q` parameter to search for different topics.

### Use a Different AI Model

Edit the "Ollama AI Summary" node and change the `model` parameter to use:
- `llama3.1:8b` - Fast, efficient
- `gpt-oss:latest` - Higher quality (if installed)
- `nomic-embed-text:latest` - For embeddings

### Add More Services

You can extend the workflow by adding nodes for:
- **Firecrawl**: Scrape full webpage content
- **Crawl4ai**: Advanced web crawling with AI
- **Docling**: Process PDFs and documents
- **Supabase**: Alternative database storage
- **n8n Worker**: Offload heavy processing

## Example Use Cases

1. **Research Assistant**: Search → Scrape → Summarize → Store
2. **Content Pipeline**: Crawl → Process → Extract → Embed → Store
3. **Data Aggregator**: Search → Collect → Deduplicate → Analyze → Export
4. **Document Processor**: Upload → Convert → Extract → Vectorize → Index

## Troubleshooting

### Workflow Fails on Ollama Node

**Problem**: Ollama model not found
**Solution**: Make sure you've pulled a model:
```bash
ollama pull llama3.1:8b
```

### Database Connection Error

**Problem**: Can't connect to Supabase
**Solution**:
1. Check that Supabase services are running: `docker ps | grep supabase`
2. Verify service role key in `supabase/.env` (SUPABASE_SERVICE_KEY)
3. Make sure the `research_results` table exists in the `supabase` database
4. Test the PostgREST endpoint: `curl http://supabase.localhost/rest/v1/research_results`

### SearXNG Returns No Results

**Problem**: Search returns empty
**Solution**:
1. Check SearXNG is running: http://searxng.localhost
2. Try a different search query
3. Check SearXNG logs: `docker logs searxng`

## Next Steps

After getting comfortable with the example workflow, try:

1. **Create a vector search workflow**: Use Qdrant to store and search embeddings
2. **Build a document pipeline**: Process PDFs with Docling and store in NocoDB
3. **Set up automated research**: Schedule workflows to run periodically
4. **Connect to external APIs**: Add webhooks and API integrations

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Workflow Templates](https://n8n.io/workflows/)
