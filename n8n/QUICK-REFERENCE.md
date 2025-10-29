# n8n Quick Reference

Quick copy-paste snippets for connecting to your local AI stack services.

## Service Endpoints (Internal Docker Network)

```
SearXNG:        http://searxng:8080
Firecrawl:      http://firecrawl-api:3002
Crawl4ai:       http://crawl4ai:11235
Docling:        http://docling:5000
Ollama:         http://host.docker.internal:11434
Qdrant:         http://qdrant:6333
NocoDB:         http://nocodb:8080
Supabase Kong:  http://supabase-kong:8000
PostgreSQL:     common-postgres:5432
Redis:          common-redis:6379
```

## Common HTTP Request Snippets

### SearXNG - Web Search

```json
{
  "url": "http://searxng:8080/search",
  "method": "GET",
  "queryParameters": {
    "q": "{{ $json.query }}",
    "format": "json",
    "categories": "general"
  }
}
```

### Ollama - AI Generation

```json
{
  "url": "http://host.docker.internal:11434/api/generate",
  "method": "POST",
  "body": {
    "model": "llama3.1:8b",
    "prompt": "{{ $json.prompt }}",
    "stream": false
  }
}
```

### Ollama - AI Chat

```json
{
  "url": "http://host.docker.internal:11434/api/chat",
  "method": "POST",
  "body": {
    "model": "llama3.1:8b",
    "messages": [
      {
        "role": "user",
        "content": "{{ $json.question }}"
      }
    ],
    "stream": false
  }
}
```

### Ollama - Generate Embeddings

```json
{
  "url": "http://host.docker.internal:11434/api/embeddings",
  "method": "POST",
  "body": {
    "model": "nomic-embed-text:latest",
    "prompt": "{{ $json.text }}"
  }
}
```

### Firecrawl - Scrape Webpage

```json
{
  "url": "http://firecrawl-api:3002/v0/scrape",
  "method": "POST",
  "body": {
    "url": "{{ $json.webpage_url }}",
    "formats": ["markdown", "html"],
    "onlyMainContent": true
  }
}
```

### Crawl4ai - Crawl with AI

```json
{
  "url": "http://crawl4ai:11235/crawl",
  "method": "POST",
  "body": {
    "urls": ["{{ $json.url }}"],
    "priority": 1,
    "crawler_params": {
      "word_count_threshold": 10,
      "extraction_strategy": "LLMExtractionStrategy",
      "chunking_strategy": "RegexChunking"
    }
  }
}
```

### Qdrant - Create Collection

```json
{
  "url": "http://qdrant:6333/collections/{{ $json.collection_name }}",
  "method": "PUT",
  "body": {
    "vectors": {
      "size": 768,
      "distance": "Cosine"
    }
  }
}
```

### Qdrant - Insert Point

```json
{
  "url": "http://qdrant:6333/collections/{{ $json.collection_name }}/points",
  "method": "PUT",
  "body": {
    "points": [
      {
        "id": "{{ $json.id }}",
        "vector": "{{ $json.embedding }}",
        "payload": "{{ $json.metadata }}"
      }
    ]
  }
}
```

### Qdrant - Search

```json
{
  "url": "http://qdrant:6333/collections/{{ $json.collection_name }}/points/search",
  "method": "POST",
  "body": {
    "vector": "{{ $json.query_embedding }}",
    "limit": 5,
    "with_payload": true
  }
}
```

### NocoDB - Get Records

```json
{
  "url": "http://nocodb:8080/api/v1/db/data/v1/{{ $json.base_id }}/{{ $json.table_id }}",
  "method": "GET",
  "headers": {
    "xc-token": "{{ $credentials.nocodb.token }}"
  }
}
```

### NocoDB - Create Record

```json
{
  "url": "http://nocodb:8080/api/v1/db/data/v1/{{ $json.base_id }}/{{ $json.table_id }}",
  "method": "POST",
  "headers": {
    "xc-token": "{{ $credentials.nocodb.token }}"
  },
  "body": {
    "field1": "{{ $json.value1 }}",
    "field2": "{{ $json.value2 }}"
  }
}
```

## PostgreSQL Queries

### Common PostgreSQL Operations

**Create Table:**
```sql
CREATE TABLE IF NOT EXISTS my_table (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  embedding vector(768),
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Insert Data:**
```sql
INSERT INTO my_table (title, content)
VALUES ('{{ $json.title }}', '{{ $json.content }}')
RETURNING *;
```

**Query Data:**
```sql
SELECT * FROM my_table
WHERE title ILIKE '%{{ $json.search }}%'
ORDER BY created_at DESC
LIMIT 10;
```

**Update Data:**
```sql
UPDATE my_table
SET content = '{{ $json.new_content }}'
WHERE id = {{ $json.id }}
RETURNING *;
```

## n8n Expression Snippets

### Access Previous Node Data

```javascript
// Get single value from previous node
{{ $json.field_name }}

// Get all items
{{ $items }}

// Get specific item
{{ $items[0].json.field }}

// Current date/time
{{ $now }}
{{ $today }}

// Environment variables
{{ $env.MY_VAR }}
```

### JavaScript Code Examples

**Split Text into Chunks:**
```javascript
const text = $input.item.json.content;
const chunkSize = 500;
const chunks = [];

for (let i = 0; i < text.length; i += chunkSize) {
  chunks.push({
    chunk: text.slice(i, i + chunkSize),
    index: i / chunkSize
  });
}

return chunks.map(c => ({ json: c }));
```

**Clean and Format Text:**
```javascript
const text = $input.item.json.raw_text;

const cleaned = text
  .replace(/\s+/g, ' ')  // Replace multiple spaces
  .replace(/\n+/g, '\n') // Replace multiple newlines
  .trim();               // Remove leading/trailing whitespace

return [{ json: { cleaned_text: cleaned } }];
```

**Generate Unique ID:**
```javascript
const crypto = require('crypto');
const id = crypto.randomBytes(16).toString('hex');

return [{ json: { id, ...($input.item.json) } }];
```

**Parse JSON String:**
```javascript
const jsonString = $input.item.json.response;
const parsed = JSON.parse(jsonString);

return [{ json: parsed }];
```

## Common Workflow Patterns

### Pattern 1: Search → Scrape → Summarize

```
Manual/Webhook Trigger
  → SearXNG (search)
  → Loop (iterate results)
    → Firecrawl (scrape each URL)
    → Ollama (summarize content)
    → PostgreSQL (store results)
```

### Pattern 2: Document → Vectorize → Store

```
File Upload
  → Docling (convert to text)
  → Code (split into chunks)
  → Loop (process each chunk)
    → Ollama (generate embedding)
    → Qdrant (store vector)
  → PostgreSQL (store metadata)
```

### Pattern 3: Scheduled Research

```
Schedule Trigger (cron)
  → SearXNG (search topics)
  → Filter (top N results)
  → Crawl4ai (extract content)
  → Ollama (analyze & summarize)
  → NocoDB (update dashboard)
```

### Pattern 4: RAG Query

```
Webhook (receive question)
  → Ollama (generate query embedding)
  → Qdrant (vector search)
  → Code (format context)
  → Ollama (generate answer with context)
  → Respond to Webhook
```

## Useful n8n Expressions

```javascript
// Convert array to JSON string
{{ JSON.stringify($json.array) }}

// Parse JSON from string
{{ JSON.parse($json.string) }}

// Format date
{{ $now.toFormat('yyyy-MM-dd') }}

// Get array length
{{ $json.array.length }}

// Check if field exists
{{ $json.field ? $json.field : 'default' }}

// Join array
{{ $json.array.join(', ') }}

// Filter array
{{ $json.array.filter(item => item.score > 0.5) }}

// Map array
{{ $json.array.map(item => item.name) }}

// Math operations
{{ Math.round($json.score * 100) }}
{{ Math.max(...$json.scores) }}

// String operations
{{ $json.text.toLowerCase() }}
{{ $json.text.toUpperCase() }}
{{ $json.text.slice(0, 100) }}
{{ $json.text.split(' ').length }}
```

## Debugging Tips

1. **Test individual nodes**: Click "Execute Node" instead of running entire workflow
2. **Use console.log in Code nodes**: Output appears in execution data
3. **Check node output**: Click on node to see input/output data
4. **Enable "Always Output Data"**: In node settings for debugging
5. **Use "Sticky Notes"**: Add notes to document your workflow
6. **View execution history**: Check past runs in the executions tab

## Common Issues

**"Cannot connect to host.docker.internal"**
- Ollama runs on host, not in Docker
- Use `host.docker.internal` instead of `localhost`

**"Credentials not found"**
- Create credential in Settings → Credentials
- Match credential name in workflow

**"Query returned no results"**
- Check service is running: `docker ps`
- Test URL with curl/browser
- Check service logs

**"Execution timed out"**
- Increase timeout in workflow settings
- Break into smaller workflows
- Use async/queue patterns

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Expression Reference](https://docs.n8n.io/code-examples/expressions/)
- [Node Reference](https://docs.n8n.io/integrations/)
- [Community Workflows](https://n8n.io/workflows/)
