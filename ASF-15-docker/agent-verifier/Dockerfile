# ASF Agent Verifier Bot - Production Docker Image
FROM node:20-alpine AS builder

# Add required system dependencies for script execution
RUN apk add --no-cache bash curl jq git

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy bot code
COPY discord-asf-bot.js ./
COPY fake-agent-detector.sh ./

# Make scripts executable
RUN chmod +x fake-agent-detector.sh

# Production stage
FROM node:20-alpine

# Install runtime dependencies only
RUN apk add --no-cache bash curl jq tini

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs discord-asf-bot.js ./
COPY --chown=nodejs:nodejs fake-agent-detector.sh ./

# Ensure scripts are executable
RUN chmod +x fake-agent-detector.sh

# Use non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "process.exit(0)" || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start bot
CMD ["node", "discord-asf-bot.js"]