.PHONY: help build up down logs status clean test health

# Default environment file
ENV_FILE ?= .env

# Load environment variables
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Default values
HOST_PORT ?= 18001

help: ## Show this help message
	@echo "ArXiv MCP Server - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup - copy env.example to .env
	@if [ ! -f .env ]; then \
		cp env.example .env; \
		echo "✅ Created .env file from env.example"; \
		echo "⚠️  Please edit .env with your configuration"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

build: ## Build the custom arxiv-mcp-server image
	@echo "🔨 Building ArXiv MCP Server image..."
	docker-compose build

up: ## Start the services
	@echo "🚀 Starting ArXiv MCP Server..."
	docker-compose up -d
	@echo "✅ Services started on port $(HOST_PORT)"
	@echo "🔗 OpenWebUI Tool URL: http://localhost:$(HOST_PORT)"

down: ## Stop the services
	@echo "🛑 Stopping ArXiv MCP Server..."
	docker-compose down

restart: down up ## Restart the services

logs: ## View logs from all services
	docker-compose logs -f

logs-mcpo: ## View logs from MCPO wrapper only
	docker-compose logs -f mcpo-wrapper

logs-init: ## View logs from init container
	docker-compose logs arxiv-init

status: ## Show status of all services
	@echo "📊 Service Status:"
	@docker-compose ps

health: ## Check health of the service
	@echo "🏥 Health Check:"
	@curl -f http://localhost:$(HOST_PORT)/health 2>/dev/null && echo "✅ Service is healthy" || echo "❌ Service is unhealthy"

test: ## Test the service with paper search and analysis
	@echo "🧪 Testing ArXiv MCP Server..."
	@echo "📋 Testing search functionality..."
	@curl -X POST http://localhost:$(HOST_PORT)/search \
		-H "Content-Type: application/json" \
		-d '{"query": "attention mechanisms", "max_results": 1}' \
		2>/dev/null | jq . || echo "❌ Search test failed"
	@echo "📄 Testing paper loading for analysis..."
	@curl -X POST http://localhost:$(HOST_PORT)/load_article_to_context \
		-H "Content-Type: application/json" \
		-d '{"title": "Attention Is All You Need"}' \
		2>/dev/null && echo "✅ Load test successful" || echo "❌ Load test failed"

clean: ## Clean up containers, networks, and volumes
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	docker system prune -f
	@echo "✅ Cleanup complete"

tools: ## List available MCP tools
	@echo "🔧 Available ArXiv MCP Tools:"
	@echo "  📋 search_arxiv - Find papers by keywords, authors, abstracts"
	@echo "  📄 get_details - Retrieve paper metadata and arXiv links"
	@echo "  🧠 load_article_to_context - Load paper content into LLM (PRIMARY)"
	@echo "  🔗 get_article_url - Get direct arXiv paper URLs"
	@echo "  💾 download_article - Optional paper download"

analyze: ## Test paper analysis workflow
	@echo "🔬 Testing complete analysis workflow..."
	@echo "1️⃣ Searching for attention mechanism papers..."
	@curl -s -X POST http://localhost:$(HOST_PORT)/search \
		-H "Content-Type: application/json" \
		-d '{"query": "attention mechanisms transformers", "max_results": 1}' | jq -r '.results[0].title' 2>/dev/null || echo "Search failed"
	@echo "2️⃣ Getting paper details with source link..."
	@curl -s -X POST http://localhost:$(HOST_PORT)/get_details \
		-H "Content-Type: application/json" \
		-d '{"title": "Attention Is All You Need"}' | jq -r '.arxiv_url' 2>/dev/null || echo "Details failed"
	@echo "3️⃣ Loading paper for analysis..."
	@curl -s -X POST http://localhost:$(HOST_PORT)/load_article_to_context \
		-H "Content-Type: application/json" \
		-d '{"title": "Attention Is All You Need"}' >/dev/null && echo "✅ Analysis workflow complete" || echo "❌ Analysis failed"

update: ## Update the arxiv-mcp-server source code
	@echo "🔄 Updating ArXiv MCP Server..."
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✅ Update completed"

portainer-stack: ## Generate Portainer stack configuration
	@echo "📋 Portainer Stack Configuration:"
	@echo ""
	@echo "Stack Name: arxiv-mcp-server"
	@echo "Environment Variables:"
	@echo "  HOST_PORT=$(HOST_PORT)"
	@echo "  DOWNLOAD_PATH=/tmp/arxiv_temp"
	@echo ""
	@echo "🎯 Purpose: Paper analysis with source links (no persistent storage)"
	@echo ""
	@echo "Docker Compose Content:"
	@cat docker-compose.yml

dev: ## Development mode - build and run with verbose logging
	@echo "🛠️  Starting in development mode..."
	docker-compose build
	docker-compose up --build

monitor: ## Monitor resource usage
	@echo "📈 Monitoring resource usage (Press Ctrl+C to stop):"
	@watch -n 2 'docker stats $$(docker-compose ps -q) --no-stream'

shell: ## Open shell in the running container
	docker-compose exec mcpo-wrapper /bin/sh

# Advanced targets
.advanced:

pull: ## Pull latest images
	docker-compose pull

validate: ## Validate docker-compose.yml
	docker-compose config

reset: clean setup ## Reset everything - clean and setup again
