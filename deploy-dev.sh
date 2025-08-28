#!/bin/bash

# Artemis Development Build and Deployment Script
# This script builds Artemis from source and deploys it

set -e

echo "🏹 Artemis Development Deployment Script"
echo "========================================"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📋 Please copy .env.example to .env and configure your settings:"
    echo "   cp .env.example .env"
    echo "   nano .env  # Edit with your configuration"
    exit 1
fi

# Source environment variables
source .env

# Validate required environment variables
required_vars=("WSS" "OPENSEA_API_KEY" "PRIVATE_KEY" "ARB_CONTRACT_ADDRESS" "BID_PERCENTAGE")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ Missing required environment variables:"
    printf "   - %s\n" "${missing_vars[@]}"
    echo ""
    echo "📝 Please edit your .env file and set these variables."
    exit 1
fi

echo "✅ Environment configuration validated"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "📋 Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"

# Check if Docker Compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ Docker Compose not found!"
    echo "📋 Please install Docker Compose and try again."
    exit 1
fi

echo "✅ Docker Compose is available"
echo ""

# Check if Rust is available for local development
if command -v cargo >/dev/null 2>&1; then
    echo "🦀 Rust toolchain detected"
    echo "🔧 Attempting to build locally first..."
    
    # Try to run a quick check
    if cargo check --bin artemis; then
        echo "✅ Local Rust build successful"
        echo "🚀 You can also run locally with: cargo run --bin artemis -- [args]"
    else
        echo "⚠️  Local Rust build failed, proceeding with Docker..."
    fi
    echo ""
fi

# Change to docker directory and update docker-compose for development build
cd docker

# Create a development docker-compose override
cat > docker-compose.dev.yml << EOF
version: '3.9'
services:
  artemis:
    build: 
      context: ..
      dockerfile: Dockerfile
    image: artemis:dev
EOF

echo "🔧 Building and starting Artemis from source..."
echo "⚠️  This may take 10-20 minutes for the first build..."
echo ""

# Build and start services with development override
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d

echo ""
echo "🎉 Artemis development deployment completed!"
echo ""
echo "📊 Monitoring URLs:"
echo "   - Grafana:    http://localhost:3000 (admin/artemis)"
echo "   - Prometheus: http://localhost:9090"
echo ""
echo "📋 Useful commands:"
echo "   - View logs:     docker-compose logs -f artemis"
echo "   - Stop services: docker-compose down"
echo "   - Rebuild:       docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d"
echo "   - Debug build:   docker-compose -f docker-compose.yml -f docker-compose.dev.yml build --no-cache artemis"
echo ""
echo "⚠️  Note: Development builds may fail due to dependency issues with git repositories."
echo "    For production deployments, use ./deploy.sh which uses pre-built images."