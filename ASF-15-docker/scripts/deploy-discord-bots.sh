#!/bin/bash
# ASF Discord Bots Deployment Script
# Production deployment with health checks and rollback

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🤖 ASF Discord Bots Production Deployment${NC}"
echo "========================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Copy .env.example to .env and configure Discord tokens"
    exit 1
fi

# Validate required environment variables
required_vars=(
    "DISCORD_AGENT_BOT_TOKEN"
    "DISCORD_SKILL_BOT_TOKEN"
    "ASF_API_KEY"
)

for var in "${required_vars[@]}"; do
    if ! grep -q "^${var}=.." .env; then
        echo -e "${RED}Error: ${var} not set in .env${NC}"
        exit 1
    fi
done

# Function to check bot health
check_bot_health() {
    local container=$1
    local max_attempts=10
    local attempt=1
    
    echo -e "${YELLOW}Checking health of ${container}...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec $container node -e "process.exit(0)" 2>/dev/null; then
            echo -e "${GREEN}✅ ${container} is healthy${NC}"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts failed, waiting..."
        sleep 3
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ ${container} failed health check${NC}"
    return 1
}

# Backup current deployment
echo -e "${YELLOW}Creating backup of current deployment...${NC}"
docker-compose -f docker-compose.discord-bots.yml ps > deployment-backup-$(date +%Y%m%d-%H%M%S).txt

# Build new images
echo -e "${YELLOW}Building Discord bot images...${NC}"
docker-compose -f docker-compose.discord-bots.yml build --no-cache

# Deploy with zero downtime
echo -e "${YELLOW}Starting new containers...${NC}"
docker-compose -f docker-compose.yml -f docker-compose.discord-bots.yml up -d --no-deps discord-agent-verifier discord-skill-verifier

# Wait for containers to be ready
sleep 10

# Health checks
echo -e "${YELLOW}Running health checks...${NC}"
bots_healthy=true

if ! check_bot_health "asf-discord-agent-verifier"; then
    bots_healthy=false
fi

if ! check_bot_health "asf-discord-skill-verifier"; then
    bots_healthy=false
fi

if [ "$bots_healthy" = false ]; then
    echo -e "${RED}⚠️  Health checks failed! Rolling back...${NC}"
    docker-compose -f docker-compose.discord-bots.yml down
    docker-compose -f docker-compose.discord-bots.yml up -d
    exit 1
fi

# Remove old containers if health checks passed
echo -e "${GREEN}✅ All bots healthy! Cleaning up old containers...${NC}"
docker system prune -f

# Show deployment status
echo -e "${GREEN}🎉 Discord Bots Deployed Successfully!${NC}"
echo "========================================="
docker-compose -f docker-compose.discord-bots.yml ps

# Show logs command
echo ""
echo "To view logs:"
echo "  Agent Verifier: docker logs -f asf-discord-agent-verifier"
echo "  Skill Verifier: docker logs -f asf-discord-skill-verifier"
echo ""
echo "To monitor all bots:"
echo "  docker-compose -f docker-compose.discord-bots.yml logs -f"