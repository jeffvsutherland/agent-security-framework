#!/usr/bin/env python3
"""
Docker Setup + AgentFriday Containerization for macOS
Securely containerizes AgentFriday with proper isolation
"""

import subprocess
import os
import sys
import json
from pathlib import Path

class DockerAgentFridaySetup:
    def __init__(self):
        self.home_dir = Path.home()
        self.docker_dir = self.home_dir / "agentfriday-docker"
        self.secrets_dir = self.docker_dir / "secrets"
        self.data_dir = self.docker_dir / "data"
        self.logs_dir = self.docker_dir / "logs"
        
    def check_docker_installed(self):
        """Check if Docker Desktop is installed"""
        try:
            result = subprocess.run(['docker', '--version'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Docker found: {result.stdout.strip()}")
                return True
            return False
        except FileNotFoundError:
            return False
    
    def install_docker_desktop(self):
        """Install Docker Desktop via Homebrew"""
        print("🚀 Installing Docker Desktop...")
        
        # Check if Homebrew is installed
        try:
            subprocess.run(['brew', '--version'], check=True, 
                          capture_output=True)
        except (FileNotFoundError, subprocess.CalledProcessError):
            print("❌ Homebrew not found. Installing Homebrew first...")
            install_brew = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            subprocess.run(install_brew, shell=True, check=True)
        
        # Install Docker Desktop
        subprocess.run(['brew', 'install', '--cask', 'docker'], check=True)
        print("✅ Docker Desktop installed")
        print("📋 Please start Docker Desktop app and come back")
        input("Press Enter when Docker Desktop is running...")
    
    def create_directories(self):
        """Create necessary directories for AgentFriday"""
        print("📁 Creating directory structure...")
        
        dirs = [self.docker_dir, self.secrets_dir, self.data_dir, self.logs_dir]
        for directory in dirs:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"   Created: {directory}")
    
    def create_dockerfile(self):
        """Create secure Dockerfile for AgentFriday"""
        dockerfile_content = """# AgentFriday Secure Container
FROM python:3.11-slim

# Security: Create non-root user
RUN groupadd -r agentfriday && useradd -r -g agentfriday -u 1000 agentfriday

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    curl \\
    git \\
    && rm -rf /var/lib/apt/lists/* \\
    && apt-get clean

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Node.js and Clawdbot (if needed)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \\
    && apt-get install -y nodejs

# Create directories with proper permissions
RUN mkdir -p /app/data /app/logs /app/secrets \\
    && chown -R agentfriday:agentfriday /app

# Copy application code
COPY --chown=agentfriday:agentfriday . .

# Switch to non-root user
USER agentfriday

# Expose port (adjust as needed)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \\
    CMD curl -f http://localhost:8080/health || exit 1

# Entry point
CMD ["python", "agentfriday_main.py"]
"""
        
        dockerfile_path = self.docker_dir / "Dockerfile"
        with open(dockerfile_path, 'w') as f:
            f.write(dockerfile_content)
        print(f"✅ Created Dockerfile: {dockerfile_path}")
    
    def create_requirements_txt(self):
        """Create requirements.txt for AgentFriday"""
        requirements = """# AgentFriday Dependencies
requests>=2.31.0
anthropic>=0.7.0
openai>=1.0.0
python-dotenv>=1.0.0
pydantic>=2.0.0
fastapi>=0.100.0
uvicorn>=0.23.0
aiohttp>=3.8.0
"""
        
        requirements_path = self.docker_dir / "requirements.txt"
        with open(requirements_path, 'w') as f:
            f.write(requirements)
        print(f"✅ Created requirements.txt: {requirements_path}")
    
    def create_docker_compose(self):
        """Create secure docker-compose.yml"""
        compose_content = """version: '3.8'

services:
  agentfriday:
    build: .
    container_name: agentfriday-secure
    
    # Security settings
    user: "1000:1000"
    read_only: true
    cap_drop:
      - ALL
    cap_add:
      - SETGID
      - SETUID
    
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
    
    # Network isolation
    networks:
      - agentfriday-net
    
    # Port mapping (only if needed)
    # ports:
    #   - "8080:8080"
    
    # Volume mounts
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
      - ./secrets:/app/secrets:ro  # Read-only secrets
      - tmpfs:/tmp:noexec,nosuid,size=100m
    
    # Environment variables
    environment:
      - PYTHONPATH=/app
      - ENVIRONMENT=production
      - LOG_LEVEL=INFO
    
    # Restart policy
    restart: unless-stopped
    
    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  agentfriday-net:
    driver: bridge
    internal: true  # No external internet access by default
"""
        
        compose_path = self.docker_dir / "docker-compose.yml"
        with open(compose_path, 'w') as f:
            f.write(compose_content)
        print(f"✅ Created docker-compose.yml: {compose_path}")
    
    def create_agentfriday_main(self):
        """Create main AgentFriday application file"""
        main_content = """#!/usr/bin/env python3
\"\"\"
AgentFriday Main Application
Containerized AI Agent with Security Best Practices
\"\"\"

import os
import logging
from pathlib import Path
from fastapi import FastAPI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/agentfriday.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# FastAPI app for health checks
app = FastAPI(title="AgentFriday", version="1.0.0")

@app.get("/health")
async def health_check():
    \"\"\"Health check endpoint\"\"\"
    return {"status": "healthy", "agent": "AgentFriday"}

class AgentFriday:
    def __init__(self):
        self.data_dir = Path("/app/data")
        self.secrets_dir = Path("/app/secrets")
        self.logs_dir = Path("/app/logs")
        
        # Ensure directories exist
        for directory in [self.data_dir, self.logs_dir]:
            directory.mkdir(parents=True, exist_ok=True)
    
    def load_secrets(self):
        \"\"\"Securely load secrets from mounted volume\"\"\"
        secrets_file = self.secrets_dir / "api_keys.json"
        if secrets_file.exists():
            with open(secrets_file, 'r') as f:
                return json.load(f)
        return {}
    
    def run(self):
        \"\"\"Main agent loop\"\"\"
        logger.info("🤖 AgentFriday starting in secure container...")
        
        # Load configuration
        secrets = self.load_secrets()
        
        # Your AgentFriday logic here
        logger.info("✅ AgentFriday initialized successfully")
        
        # Keep container running
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=8080)

if __name__ == "__main__":
    agent = AgentFriday()
    agent.run()
"""
        
        main_path = self.docker_dir / "agentfriday_main.py"
        with open(main_path, 'w') as f:
            f.write(main_content)
        print(f"✅ Created agentfriday_main.py: {main_path}")
    
    def create_secrets_template(self):
        """Create secrets template"""
        secrets_template = {
            "anthropic_api_key": "your_anthropic_key_here",
            "openai_api_key": "your_openai_key_here",
            "telegram_bot_token": "your_telegram_token_here",
            "other_api_keys": {}
        }
        
        secrets_path = self.secrets_dir / "api_keys.json.template"
        with open(secrets_path, 'w') as f:
            json.dump(secrets_template, f, indent=2)
        
        print(f"✅ Created secrets template: {secrets_path}")
        print("🔐 Copy this to api_keys.json and add your real API keys")
    
    def create_security_script(self):
        """Create security hardening script"""
        security_script = """#!/bin/bash
# AgentFriday Security Hardening Script

echo "🛡️  Applying security hardening..."

# Set proper file permissions
chmod 700 secrets/
chmod 600 secrets/api_keys.json 2>/dev/null || echo "⚠️  Create api_keys.json first"
chmod 755 data/
chmod 755 logs/

# Create .dockerignore for security
cat > .dockerignore << EOF
secrets/api_keys.json
.git/
.env
*.log
__pycache__/
.pytest_cache/
node_modules/
EOF

echo "✅ Security hardening applied"
echo "🔐 Remember to:"
echo "   1. Copy api_keys.json.template to api_keys.json"
echo "   2. Add your real API keys to api_keys.json"
echo "   3. Never commit api_keys.json to git"
"""
        
        script_path = self.docker_dir / "harden_security.sh"
        with open(script_path, 'w') as f:
            f.write(security_script)
        os.chmod(script_path, 0o755)
        print(f"✅ Created security script: {script_path}")
    
    def build_and_run(self):
        """Build and run the containerized AgentFriday"""
        print("🔨 Building AgentFriday container...")
        os.chdir(self.docker_dir)
        
        # Run security hardening
        subprocess.run(['./harden_security.sh'], check=True)
        
        # Build container
        subprocess.run(['docker-compose', 'build'], check=True)
        
        print("✅ Container built successfully!")
        print("\n🚀 To start AgentFriday:")
        print(f"   cd {self.docker_dir}")
        print("   docker-compose up -d")
        print("\n📋 Management commands:")
        print("   docker-compose logs -f    # View logs")
        print("   docker-compose stop       # Stop container")
        print("   docker-compose down       # Stop and remove")
        print("   docker-compose exec agentfriday bash  # Shell access")
    
    def setup(self):
        """Main setup process"""
        print("🤖 AgentFriday Docker Setup Starting...")
        print("="*50)
        
        # Check Docker
        if not self.check_docker_installed():
            self.install_docker_desktop()
        
        # Wait for Docker to be ready
        print("⏳ Waiting for Docker to be ready...")
        while True:
            try:
                result = subprocess.run(['docker', 'info'], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    break
                print("   Docker daemon not ready, waiting...")
                import time
                time.sleep(5)
            except Exception as e:
                print(f"   Waiting for Docker: {e}")
                import time
                time.sleep(5)
        
        print("✅ Docker is ready!")
        
        # Create project structure
        self.create_directories()
        self.create_dockerfile()
        self.create_requirements_txt()
        self.create_docker_compose()
        self.create_agentfriday_main()
        self.create_secrets_template()
        self.create_security_script()
        
        # Build and setup
        self.build_and_run()
        
        print("\n" + "="*50)
        print("🎉 AgentFriday Docker Setup Complete!")
        print(f"📁 Project directory: {self.docker_dir}")
        print("🔐 Don't forget to setup your API keys in secrets/api_keys.json")

def main():
    setup = DockerAgentFridaySetup()
    setup.setup()

if __name__ == "__main__":
    main()