# ASF Platform Integration SDK - Docker Deployment Makefile

.PHONY: all build up down restart logs clean test deploy

# Default target
all: build up

# Build all containers
build:
	@echo "Building ASF containers..."
	docker-compose build

# Start all services
up:
	@echo "Starting ASF services..."
	docker-compose up -d
	@echo "Services starting... Check status with 'make status'"

# Stop all services
down:
	@echo "Stopping ASF services..."
	docker-compose down

# Restart all services
restart: down up

# View logs
logs:
	docker-compose logs -f

# View logs for specific service
logs-%:
	docker-compose logs -f $*

# Clean everything (including volumes)
clean:
	@echo "Cleaning ASF deployment..."
	docker-compose down -v
	docker system prune -f

# Check service status
status:
	@echo "ASF Service Status:"
	@docker-compose ps
	@echo "\nHealth Check Status:"
	@docker ps --filter "name=asf-" --format "table {{.Names}}\t{{.Status}}"

# Run tests
test:
	@echo "Running ASF integration tests..."
	docker-compose run --rm api npm test
	docker-compose run --rm webhook npm test

# Build SDKs
build-sdks:
	@echo "Building ASF SDKs..."
	docker-compose --profile build run --rm sdk-builder

# Deploy to production
deploy: test
	@echo "Deploying ASF to production..."
	./scripts/deploy-production.sh

# Development mode with hot reload
dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Database migrations
migrate:
	docker-compose exec asf-api npm run migrate

# Backup database
backup:
	@echo "Backing up ASF database..."
	./scripts/backup-db.sh

# Monitor services
monitor:
	@echo "Opening monitoring dashboard..."
	@echo "API Health: http://localhost:8080/health"
	@echo "Dashboard: http://localhost:3000"
	@echo "API Docs: http://localhost:8080/docs"

# Initialize environment
init:
	@echo "Initializing ASF environment..."
	cp .env.example .env
	@echo "Please edit .env file with your configuration"

# Help
help:
	@echo "ASF Platform Integration SDK - Docker Commands"
	@echo ""
	@echo "  make build      - Build all containers"
	@echo "  make up         - Start all services"
	@echo "  make down       - Stop all services"
	@echo "  make restart    - Restart all services"
	@echo "  make logs       - View all logs"
	@echo "  make logs-api   - View API logs"
	@echo "  make status     - Check service status"
	@echo "  make test       - Run integration tests"
	@echo "  make build-sdks - Build SDK packages"
	@echo "  make clean      - Remove containers and volumes"
	@echo "  make deploy     - Deploy to production"
	@echo "  make dev        - Run in development mode"
	@echo "  make monitor    - View monitoring endpoints"
	@echo ""
	@echo "Discord Bot Commands:"
	@echo "  make discord-build   - Build Discord bot containers"
	@echo "  make discord-up      - Start Discord bots"
	@echo "  make discord-down    - Stop Discord bots"
	@echo "  make discord-logs    - View Discord bot logs"
	@echo "  make discord-deploy  - Deploy Discord bots to production"
	@echo "  make discord-monitor - Monitor Discord bot health"

# Discord Bot Commands
discord-build:
	@echo "Building Discord bot containers..."
	docker-compose -f docker-compose.discord-bots.yml build

discord-up:
	@echo "Starting Discord bots..."
	docker-compose -f docker-compose.yml -f docker-compose.discord-bots.yml up -d discord-agent-verifier discord-skill-verifier
	@echo "Bots starting... Check status with 'make discord-status'"

discord-down:
	@echo "Stopping Discord bots..."
	docker-compose -f docker-compose.discord-bots.yml down

discord-restart: discord-down discord-up

discord-logs:
	docker-compose -f docker-compose.discord-bots.yml logs -f

discord-logs-agent:
	docker logs -f asf-discord-agent-verifier

discord-logs-skill:
	docker logs -f asf-discord-skill-verifier

discord-status:
	@echo "Discord Bot Status:"
	@docker-compose -f docker-compose.discord-bots.yml ps
	@echo "\nBot Health:"
	@docker ps --filter "name=discord" --format "table {{.Names}}\t{{.Status}}"

discord-deploy:
	@echo "Deploying Discord bots to production..."
	./scripts/deploy-discord-bots.sh

discord-monitor:
	@echo "Starting Discord bot monitor..."
	./scripts/monitor-discord-bots.sh