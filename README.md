# ArXiv MCP Server with OpenWebUI Integration

This project deploys the [arxiv-mcp-server](https://github.com/prashalruchiranga/arxiv-mcp-server) with an MCPO wrapper for OpenWebUI integration via Portainer.

## Features

- **arXiv Paper Analysis**: Search papers and load content into LLM context for analysis
- **Source Link Generation**: Provides direct links to arXiv papers for transparency [[memory:628821]]
- **OpenWebUI Compatible**: Wrapped with MCPO for seamless integration
- **Portainer Ready**: Docker Compose stack for easy deployment
- **Memory Efficient**: Uses temporary storage for paper processing, no persistent downloads needed

## Services

### ArXiv MCP Server
- **Port**: 18001 (internal)
- **Function**: Provides MCP server functionality for arXiv operations
- **Tools**: Search, metadata retrieval, **load_article_to_context** (primary), optional download

### MCPO Wrapper
- **Port**: 18001 (exposed)
- **Function**: Translates MCP protocol to HTTP/REST API for OpenWebUI
- **Upstream**: Connects to arxiv-mcp-server

## Quick Start

1. **Deploy in Portainer**:
   - Navigate to Stacks → Add Stack
   - Name: `arxiv-mcp-server`
   - Copy contents of `docker-compose.yml`
   - Deploy the stack

2. **Configure OpenWebUI**:
   - Settings → Tools → Add Tool
   - Name: `ArXiv MCP Server`
   - URL: `http://YOUR_HOST:18001`
   - Save configuration

3. **Test Integration**:
   ```
   Load "Attention is All You Need" paper into context for analysis
   Search for recent papers on transformers and analyze their findings
   Get paper details by Yann LeCun with source links
   ```

## Environment Variables

Create a `.env` file based on `env.example` [[memory:628824]]:

```bash
cp env.example .env
```

Configure the following variables:
- `HOST_PORT`: External port (default: 18001)
- `DOWNLOAD_PATH`: Temporary path for paper processing (auto-configured)

## Example Prompts for OpenWebUI

Once integrated, you can use these prompts for paper analysis:

- "Load the 'Attention is All You Need' paper and summarize its key contributions"
- "Find recent papers on large language models and analyze their approaches"
- "Compare the methodologies in Geoffrey Hinton's latest deep learning papers"
- "Search for reinforcement learning papers from 2024 and provide analysis with source links"
- "Load papers about transformer architectures and explain their evolution"

## Troubleshooting

### Check Service Status
```bash
docker-compose logs arxiv-server
docker-compose logs mcpo-wrapper
```

### Verify Connectivity
```bash
curl http://localhost:18001/health
```

### Common Issues
- **Port conflicts**: Ensure port 18001 is available
- **Download permissions**: Check DOWNLOAD_PATH permissions
- **Network issues**: Verify container networking

## Architecture & Workflow

```
OpenWebUI → MCPO Wrapper (Port 18001) → ArXiv MCP Server → arXiv API
                                             ↓
                                    Load papers into LLM context
                                             ↓
                                    Analysis + Source links
```

**Key Tools Available:**
- `search_arxiv`: Find papers by keywords, authors, abstracts
- `get_details`: Retrieve paper metadata and arXiv links
- `load_article_to_context`: **Primary tool** - loads paper content into LLM for analysis
- `get_article_url`: Get direct arXiv paper URLs for source linking
- `download_article`: Optional - for cases where local access is needed

The MCPO wrapper translates OpenWebUI's HTTP requests into MCP protocol calls, with emphasis on the `load_article_to_context` tool for paper analysis workflows.
