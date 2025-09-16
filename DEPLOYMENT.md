# ArXiv MCP Server Deployment Guide

This guide provides step-by-step instructions for deploying the ArXiv MCP Server with MCPO wrapper in Portainer.

## Prerequisites

- Portainer instance running
- Docker environment
- Network access to arXiv.org
- OpenWebUI instance for integration

## Deployment Steps

### 1. Prepare Environment

1. **Clone or copy project files** to your deployment environment
2. **Configure environment variables**:
   ```bash
   cp env.example .env
   # Edit .env with your specific configuration
   ```

### 2. Deploy in Portainer

#### Option A: Deploy via Portainer UI

1. **Access Portainer**:
   - Navigate to your Portainer dashboard
   - Log in with your credentials

2. **Create New Stack**:
   - Go to **Stacks** → **Add stack**
   - Name: `arxiv-mcp-server`
   - Method: **Web editor**

3. **Copy Configuration**:
   - Copy the entire contents of `docker-compose.yml`
   - Paste into the Portainer web editor

4. **Environment Variables**:
   - Scroll down to **Environment variables**
   - Add the following variables:
     ```
     HOST_PORT=18001
     DOWNLOAD_PATH=/app/downloads
     ```

5. **Deploy Stack**:
   - Click **Deploy the stack**
   - Wait for deployment to complete

#### Option B: Deploy via Git Repository

1. **Configure Git Repository**:
   - Repository URL: `https://github.com/YOUR_USERNAME/arxiv-tool`
   - Branch: `main`
   - Compose file path: `docker-compose.yml`

2. **Set Environment Variables**:
   ```
   HOST_PORT=18001
   DOWNLOAD_PATH=/app/downloads
   ```

3. **Deploy**:
   - Click **Deploy the stack**

### 3. Verify Deployment

1. **Check Container Status**:
   - Navigate to **Containers**
   - Verify both containers are running:
     - `arxiv-init` (should complete and exit)
     - `arxiv-mcpo-server` (should be running)

2. **Check Logs**:
   ```bash
   # View initialization logs
   docker logs arxiv-init
   
   # View MCPO wrapper logs
   docker logs arxiv-mcpo-server
   ```

3. **Test Connectivity**:
   ```bash
   # Health check
   curl http://YOUR_HOST:18001/health
   
   # API test
   curl http://YOUR_HOST:18001/tools
   ```

### 4. Configure OpenWebUI

1. **Access OpenWebUI Settings**:
   - Navigate to **Settings** → **Tools**

2. **Add New Tool**:
   - **Name**: `ArXiv MCP Server`
   - **URL**: `http://YOUR_HOST:18001`
   - **Description**: `Search and download academic papers from arXiv`

3. **Save Configuration**:
   - Click **Save**
   - Test the integration

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check container logs
docker logs arxiv-mcpo-server

# Common causes:
# - Port 18001 already in use
# - Insufficient memory
# - Network connectivity issues
```

#### MCPO Connection Issues
```bash
# Verify MCPO is running
curl -v http://localhost:18001/health

# Check if arxiv-init completed successfully
docker logs arxiv-init
```

#### Download Issues
```bash
# Check volume permissions
docker exec arxiv-mcpo-server ls -la /app/downloads

# Verify environment variables
docker exec arxiv-mcpo-server env | grep DOWNLOAD
```

### Service Management

#### Restart Services
```bash
# Via Portainer: Stacks → arxiv-mcp-server → Restart
# Or via Docker:
docker-compose restart
```

#### Update Configuration
```bash
# Edit stack in Portainer
# Or update docker-compose.yml and redeploy
docker-compose up -d
```

#### View Real-time Logs
```bash
# Via Portainer: Containers → arxiv-mcpo-server → Logs
# Or via Docker:
docker logs -f arxiv-mcpo-server
```

### Performance Monitoring

#### Resource Usage
- Monitor CPU and memory usage in Portainer
- Adjust resource limits if needed

#### Storage Monitoring
```bash
# Check download volume usage
docker volume inspect arxiv-tool_arxiv_downloads
```

## Integration Examples

### OpenWebUI Prompts

Once integrated, you can use these prompts in OpenWebUI:

```
Search for papers about "attention mechanisms in transformers"
Download the "Attention is All You Need" paper
Get details for papers by Geoffrey Hinton published after 2020
Find recent papers on reinforcement learning
Load the paper about BERT into context
```

### API Usage

Direct API calls for testing:

```bash
# Search papers
curl -X POST http://YOUR_HOST:18001/search \
  -H "Content-Type: application/json" \
  -d '{"query": "machine learning", "max_results": 5}'

# Download paper
curl -X POST http://YOUR_HOST:18001/download \
  -H "Content-Type: application/json" \
  -d '{"title": "Attention Is All You Need"}'
```

## Security Considerations

1. **Network Security**:
   - Ensure port 18001 is only accessible from trusted networks
   - Consider using a reverse proxy with authentication

2. **Data Storage**:
   - Downloaded papers are stored in Docker volumes
   - Implement backup strategies as needed

3. **Resource Limits**:
   - Monitor download volume size
   - Set appropriate resource limits in docker-compose.yml

## Maintenance

### Regular Tasks

1. **Update Images**:
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

2. **Clean Up Downloads**:
   ```bash
   # Remove old downloads if needed
   docker exec arxiv-mcpo-server find /app/downloads -name "*.pdf" -mtime +30 -delete
   ```

3. **Monitor Logs**:
   - Regular log review for errors
   - Log rotation configuration

### Backup

```bash
# Backup download volume
docker run --rm -v arxiv-tool_arxiv_downloads:/data -v $(pwd):/backup ubuntu tar cvf /backup/arxiv_downloads.tar /data

# Restore download volume
docker run --rm -v arxiv-tool_arxiv_downloads:/data -v $(pwd):/backup ubuntu tar xvf /backup/arxiv_downloads.tar -C /
```

## Support

For issues and questions:
- Check container logs first
- Review this troubleshooting guide
- Consult the [arxiv-mcp-server repository](https://github.com/prashalruchiranga/arxiv-mcp-server)
- OpenWebUI documentation for integration issues
