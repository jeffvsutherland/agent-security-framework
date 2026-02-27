# Multi-language SDK Builder
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install language runtimes and build tools
RUN apt-get update && apt-get install -y \
    # Common tools
    curl wget git zip unzip \
    # Node.js
    nodejs npm \
    # Python
    python3 python3-pip python3-venv \
    # Go
    golang-go \
    # Build essentials
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Install SDK build tools
RUN npm install -g typescript @types/node jest ts-jest
RUN pip3 install --no-cache-dir build twine pytest pytest-asyncio

# Copy build scripts
COPY build-scripts /workspace/build-scripts
RUN chmod +x /workspace/build-scripts/*

# Create output directories
RUN mkdir -p /workspace/sdks /workspace/artifacts

CMD ["/workspace/build-scripts/build-all-sdks.sh"]