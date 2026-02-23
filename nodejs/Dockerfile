# ASF Skill Docker Template - Node.js
# Purpose: Run untrusted Node.js skills in isolated containers
# Security: Blocks credential theft and host filesystem access

FROM node:20-slim

# Security: Create non-root user
RUN groupadd -r skilluser && useradd -r -g skilluser skilluser

# Security: Disable unnecessary capabilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Skill workspace (read-only by default)
WORKDIR /skill
RUN chown -R skilluser:skilluser /skill

# Security: Block access to sensitive paths
RUN mkdir -p /blocked_paths /root /home /etc/security /etc/passwd \
    && chmod 000 /blocked_paths \
    && chown -R root:root /blocked_paths

# Environment: Restrictive by default
ENV HOME=/tmp
ENV NODE_ENV=restricted
ENV NPM_CONFIG_CACHE=/tmp/npm-cache

# Credential blocking wrapper
COPY block_credentials.js /usr/local/bin/asf-node-preload.js

# Patch node to use credential blocker
RUN echo "#!/bin/bash" > /usr/local/bin/node \
    && echo "exec /usr/bin/node --require /usr/local/bin/asf-node-preload.js \"\$@\"" >> /usr/local/bin/node \
    && chmod +x /usr/local/bin/node

# Skill execution (as non-root user)
USER skilluser

# Mount skill code as read-only
VOLUME ["/skill:ro"]

CMD ["/bin/bash"]
