#!/bin/bash

# ArXiv MCP Server Quick Start Script
# This script sets up and deploys the ArXiv MCP Server for OpenWebUI integration

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are available"
}

# Setup environment
setup_env() {
    print_status "Setting up environment..."
    
    if [ ! -f .env ]; then
        cp env.example .env
        print_success "Created .env file from env.example"
        print_warning "You may want to edit .env to customize your configuration"
    else
        print_warning ".env file already exists, skipping creation"
    fi
}

# Deploy the services
deploy_services() {
    print_status "Deploying ArXiv MCP Server..."
    
    # Start services
    docker-compose up -d
    
    print_success "Services deployed successfully!"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for init container to complete
    print_status "Waiting for initialization to complete..."
    timeout=120
    elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if docker ps -a --filter "name=arxiv-init" --filter "status=exited" --filter "exited=0" | grep -q arxiv-init; then
            print_success "Initialization completed"
            break
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
    done
    echo ""
    
    if [ $elapsed -ge $timeout ]; then
        print_error "Initialization timed out"
        docker logs arxiv-init
        exit 1
    fi
    
    # Wait for MCPO wrapper to be ready
    print_status "Waiting for MCPO wrapper to be ready..."
    timeout=60
    elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if curl -f http://localhost:18001/health &> /dev/null; then
            print_success "MCPO wrapper is ready"
            break
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo -n "."
    done
    echo ""
    
    if [ $elapsed -ge $timeout ]; then
        print_warning "MCPO wrapper health check failed, but continuing..."
    fi
}

# Test the deployment
test_deployment() {
    print_status "Testing deployment..."
    
    # Test health endpoint
    if curl -f http://localhost:18001/health &> /dev/null; then
        print_success "Health check passed"
    else
        print_warning "Health check failed"
    fi
    
    # Show service status
    print_status "Service status:"
    docker-compose ps
}

# Show deployment info
show_info() {
    echo ""
    echo "🎉 ArXiv MCP Server deployment completed!"
    echo ""
    echo "📋 Deployment Information:"
    echo "  • Service URL: http://localhost:18001"
    echo "  • Health Check: http://localhost:18001/health"
    echo "  • Logs: docker-compose logs -f"
    echo ""
    echo "🔗 OpenWebUI Integration:"
    echo "  1. Go to OpenWebUI Settings → Tools"
    echo "  2. Add new tool:"
    echo "     Name: ArXiv MCP Server"
    echo "     URL: http://YOUR_HOST:18001"
    echo "  3. Save and test the integration"
    echo ""
    echo "📝 Example prompts for OpenWebUI (paper analysis workflow):"
    echo "  • 'Load the Attention is All You Need paper and summarize its contributions'"
    echo "  • 'Search for recent transformer papers and analyze their methodologies'"
    echo "  • 'Get details for Geoffrey Hinton papers with source links for citations'"
    echo "  • 'Compare approaches in recent reinforcement learning papers'"
    echo ""
    echo "🛠️  Management commands:"
    echo "  • Stop: docker-compose down"
    echo "  • Restart: docker-compose restart"
    echo "  • Logs: docker-compose logs -f"
    echo "  • Status: docker-compose ps"
    echo ""
    echo "📚 For more details, see DEPLOYMENT.md"
}

# Main execution
main() {
    echo "🚀 ArXiv MCP Server Quick Start"
    echo "================================"
    echo ""
    
    check_docker
    setup_env
    deploy_services
    wait_for_services
    test_deployment
    show_info
    
    print_success "Deployment completed successfully! 🎉"
}

# Run main function
main "$@"
