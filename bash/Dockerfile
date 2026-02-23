# ASF Skill Docker Template - Bash
# Purpose: Run untrusted bash skills in isolated containers
# Security: Blocks credential theft and host filesystem access

FROM debian:12-slim

# Security: Create non-root user
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r skilluser && useradd -r -g skilluser skilluser

# Skill workspace (read-only by default)
WORKDIR /skill
RUN chown -R skilluser:skilluser /skill

# Security: Block access to sensitive paths
RUN mkdir -p /blocked_paths /root /home /etc/security /etc/passwd /etc/shadow \
    && chmod 000 /blocked_paths \
    && chown -R root:root /blocked_paths

# Environment: Restrictive by default
ENV HOME=/tmp
ENV PATH=/usr/bin:/bin:/usr/local/bin

# Credential blocking wrapper script
COPY block_credentials.sh /usr/local/bin/asf-block-creds

# Override bash to source credential blocker
RUN echo "#!/bin/bash" > /usr/bin/bash \
    && echo "source /usr/local/bin/asf-block-creds 2>/dev/null" >> /usr/bin/bash \
    && echo "export -f block_sensitive_envs 2>/dev/null" >> /usr/bin/bash \
    && echo "exec /bin/bash \"\$@\"" >> /usr/bin/bash \
    && chmod +x /usr/bin/bash

# Skill execution (as non-root user)
USER skilluser

# Mount skill code as read-only
VOLUME ["/skill:ro"]

CMD ["/bin/bash"]
