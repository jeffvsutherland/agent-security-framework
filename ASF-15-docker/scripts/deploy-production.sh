#!/bin/bash

# ASF Platform Integration SDK - Production Deployment Script

set -e

echo "================================================"
echo "ASF Platform Integration SDK - Production Deploy"
echo "================================================"

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose is required but not installed. Aborting." >&2; exit 1; }

# Load environment
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create it from .env.example"
    exit 1
fi

# Validate environment variables
required_vars=("JWT_SECRET" "API_KEY_SALT" "DATABASE_URL")
for var in "${required_vars[@]}"; do
    if ! grep -q "^${var}=" .env || grep -q "^${var}=.*change-this" .env; then
        echo "Error: ${var} must be set with a secure value in .env"
        exit 1
    fi
done

# Run tests first
echo "Running integration tests..."
make test

if [ $? -ne 0 ]; then
    echo "Tests failed. Aborting deployment."
    exit 1
fi

# Backup current data
echo "Backing up database..."
./scripts/backup-db.sh

# Build new images
echo "Building Docker images..."
docker-compose build --no-cache

# Deploy with zero downtime
echo "Deploying services..."

# Start new containers alongside old ones
docker-compose up -d --scale asf-api=2

# Wait for health checks
echo "Waiting for services to be healthy..."
sleep 30

# Check health
for service in asf-api asf-dashboard webhook-service; do
    if ! docker-compose exec $service curl -f http://localhost:8080/health >/dev/null 2>&1; then
        echo "Error: $service health check failed"
        docker-compose logs $service
        exit 1
    fi
done

# Remove old containers
docker-compose up -d --scale asf-api=1 --remove-orphans

echo "================================================"
echo "Deployment completed successfully!"
echo "================================================"
echo ""
echo "Services available at:"
echo "- API: http://localhost:8080"
echo "- Dashboard: http://localhost:3000"
echo "- API Documentation: http://localhost:8080/docs"
echo ""
echo "Run 'make monitor' to view service status"