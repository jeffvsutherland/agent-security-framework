# ASF Skill Verifier Bot - Production Docker Image
FROM node:20-alpine AS builder

# Add required system dependencies for skill checking
RUN apk add --no-cache bash curl jq git grep sed gawk file

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy bot code and scripts
COPY discord-skill-bot.js ./
COPY skill-checker.sh ./

# Make scripts executable
RUN chmod +x skill-checker.sh

# Production stage
FROM node:20-alpine

# Install runtime dependencies
RUN apk add --no-cache bash curl jq git grep sed gawk file tini

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs discord-skill-bot.js ./
COPY --chown=nodejs:nodejs skill-checker.sh ./

# Create tmp directory for skill analysis
RUN mkdir -p /tmp/skill-check && chown nodejs:nodejs /tmp/skill-check

# Ensure scripts are executable
RUN chmod +x skill-checker.sh

# Use non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "process.exit(0)" || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start bot
CMD ["node", "discord-skill-bot.js"]