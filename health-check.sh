#!/bin/bash

# Artemis Health Check Script
# This script checks the status of Artemis deployment

echo "🏹 Artemis Health Check"
echo "======================="

# Check if docker-compose.yml exists
if [ ! -f "docker/docker-compose.yml" ]; then
    echo "❌ Docker compose file not found!"
    echo "📋 Make sure you're in the artemis root directory."
    exit 1
fi

cd docker

# Check if containers are running
echo "🔍 Checking container status..."
docker-compose ps

echo ""
echo "📊 Service Health:"

# Check Artemis container
if docker-compose ps artemis | grep -q "Up"; then
    echo "✅ Artemis bot: Running"
    
    # Check logs for errors
    echo "📋 Recent Artemis logs:"
    docker-compose logs --tail=10 artemis | grep -v "^artemis-bot" | tail -5
else
    echo "❌ Artemis bot: Not running"
    echo "📋 Last logs:"
    docker-compose logs --tail=10 artemis
fi

echo ""

# Check Prometheus
if docker-compose ps prometheus | grep -q "Up"; then
    echo "✅ Prometheus: Running (http://localhost:9090)"
    
    # Test Prometheus endpoint
    if curl -s http://localhost:9090/-/healthy >/dev/null 2>&1; then
        echo "   📡 API: Healthy"
    else
        echo "   ⚠️  API: Not responding"
    fi
else
    echo "❌ Prometheus: Not running"
fi

echo ""

# Check Grafana
if docker-compose ps grafana | grep -q "Up"; then
    echo "✅ Grafana: Running (http://localhost:3000)"
    
    # Test Grafana endpoint
    if curl -s http://localhost:3000/api/health >/dev/null 2>&1; then
        echo "   📡 API: Healthy"
    else
        echo "   ⚠️  API: Not responding"
    fi
else
    echo "❌ Grafana: Not running"
fi

echo ""
echo "💡 Tips:"
echo "   - View all logs:    docker-compose logs -f"
echo "   - Restart service:  docker-compose restart artemis"
echo "   - Stop all:         docker-compose down"
echo "   - Update and restart: ./deploy.sh"