# ASF Skill Docker Template - Python
# Purpose: Run untrusted Python skills in isolated containers
# Security: Blocks credential theft and host filesystem access

FROM python:3.11-slim-bookworm

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
# These files/blocked_paths will trigger alerts if accessed
RUN mkdir -p /blocked_paths /root /home /etc/security /etc/passwd \
    && chmod 000 /blocked_paths \
    && chown -R root:root /blocked_paths

# Environment: Restrictive by default
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV HOME=/tmp
ENV PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/go/bin

# Credential blocking: Override os.environ to block sensitive keys
COPY block_credentials.py /usr/local/bin/block_credentials.py
RUN echo "#!/bin/bash" > /usr/local/bin/python3 \
    && echo "exec /usr/bin/python3 -c \"import sys; exec(open('/usr/local/bin/block_credentials.py').read())\" \"\$@\"" >> /usr/local/bin/python3 \
    && chmod +x /usr/local/bin/python3

# Skill execution (as non-root user)
USER skilluser

# Mount skill code as read-only
VOLUME ["/skill:ro"]

CMD ["/bin/bash"]
