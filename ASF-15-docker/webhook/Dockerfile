# ASF Webhook Service
FROM node:20-alpine

RUN apk add --no-cache curl

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8081/health || exit 1

CMD ["node", "index.js"]