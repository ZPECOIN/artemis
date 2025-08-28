#!/bin/bash

# Artemis Deployment Script
# This script helps deploy Artemis using Docker Compose with pre-built images

set -e

echo "🏹 Artemis Deployment Script"
echo "============================"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📋 Please copy .env.example to .env and configure your settings:"
    echo "   cp .env.example .env"
    echo "   nano .env  # Edit with your configuration"
    echo ""
    echo "📖 Required configuration:"
    echo "   - WSS: Ethereum WebSocket endpoint (Infura/Alchemy)"
    echo "   - OPENSEA_API_KEY: OpenSea API key"
    echo "   - PRIVATE_KEY: Private key for transactions"
    echo "   - ARB_CONTRACT_ADDRESS: Deployed arbitrage contract address"
    echo "   - BID_PERCENTAGE: Gas bid percentage (0-100)"
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

# Pull the latest image
echo "🔄 Pulling latest Artemis image..."
docker pull ghcr.io/zpecoin/artemis:main

# Change to docker directory
cd docker

echo "🔧 Starting Artemis deployment..."
echo ""

# Start services
docker-compose up -d

echo ""
echo "🎉 Artemis deployment completed!"
echo ""
echo "📊 Monitoring URLs:"
echo "   - Grafana:    http://localhost:3000 (admin/artemis)"
echo "   - Prometheus: http://localhost:9090"
echo ""
echo "📋 Useful commands:"
echo "   - View logs:     docker-compose -f docker/docker-compose.yml logs -f artemis"
echo "   - Stop services: docker-compose -f docker/docker-compose.yml down"
echo "   - Restart:       docker-compose -f docker/docker-compose.yml restart artemis"
echo "   - Update image:  docker pull ghcr.io/zpecoin/artemis:main && docker-compose -f docker/docker-compose.yml up -d artemis"
echo ""
echo "⚠️  Remember:"
echo "   - Monitor the logs for any errors"
echo "   - Ensure your arbitrage contract is deployed and funded"
echo "   - Keep your private key secure"
echo "   - The Docker image will be pulled from GitHub Container Registry"