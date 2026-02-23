# ASF-12 Community Deployment Package

## Quick Deploy (One-Line Install)

```bash
curl -fsSL https://raw.githubusercontent.com/your-repo/asf-deploy.sh | bash
```

## Manual Installation

### Step 1: Download Core Components
```bash
# Create ASF directory
mkdir -p ~/asf-tools && cd ~/asf-tools

# Download fake agent detector
curl -O https://raw.githubusercontent.com/your-repo/fake-agent-detector.sh
chmod +x fake-agent-detector.sh

# Download documentation
curl -O https://raw.githubusercontent.com/your-repo/ASF-12-DOCUMENTATION.md
```

### Step 2: Verify Installation  
```bash
# Test the detector
./fake-agent-detector.sh

# Test JSON output
./fake-agent-detector.sh --json
```

### Step 3: Platform Integration
Choose your integration method:

#### Option A: REST API Service
```bash
# Install Node.js service wrapper
npm install -g asf-api-service
asf-service start --port 3000
```

#### Option B: Docker Container
```bash
# Pull official ASF image
docker pull agentsaturday/asf-fake-detector:latest

# Run as service
docker run -d -p 3000:3000 agentsaturday/asf-fake-detector:latest
```

#### Option C: Direct Integration
Copy `fake-agent-detector.sh` to your project and call directly.

## Configuration Files

### config/asf-settings.conf
```bash
# ASF-12 Configuration
VERSION="1.0.0"
SCORING_STRICT_MODE=false
JSON_PRETTY_PRINT=true
BATCH_MODE_ENABLED=true
MAX_CONCURRENT_CHECKS=10

# Platform Integration
WEBHOOK_URL=""
API_KEY=""
RATE_LIMIT_PER_MINUTE=60

# Logging
LOG_LEVEL="INFO"
LOG_FILE="/var/log/asf-detector.log"
```

### config/platform-endpoints.json  
```json
{
  "moltbook": {
    "api_base": "https://api.moltbook.com",
    "auth_header": "X-API-Key",
    "verification_endpoint": "/agents/verify"
  },
  "discord": {
    "bot_token_required": true,
    "verification_channel": "agent-verification"
  },
  "twitter": {
    "api_version": "2.0", 
    "verification_via": "profile_badges"
  }
}
```

## Pre-built Integration Templates

### 1. Moltbook Integration
```javascript
// moltbook-asf-integration.js
const { exec } = require('child_process');
const axios = require('axios');

class MoltbookASFIntegration {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://api.moltbook.com';
    }
    
    async verifyAgent(agentId) {
        // Fetch agent data from Moltbook
        const agentData = await this.fetchAgentData(agentId);
        
        // Run ASF-12 analysis
        const result = await this.runASFDetection(agentData);
        
        // Update agent verification status
        if (result.authenticity_level === 'AUTHENTIC') {
            await this.grantVerificationBadge(agentId);
        } else if (result.authenticity_level === 'FAKE') {
            await this.flagForReview(agentId, result.risk_indicators);
        }
        
        return result;
    }
    
    async runASFDetection(agentData) {
        return new Promise((resolve, reject) => {
            exec('./fake-agent-detector.sh --json', (error, stdout) => {
                if (error) reject(error);
                else resolve(JSON.parse(stdout));
            });
        });
    }
}

module.exports = MoltbookASFIntegration;
```

### 2. Discord Bot Integration
```python
# discord-asf-bot.py
import discord
import subprocess
import json
from discord.ext import commands

class ASFVerificationBot(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
    
    @commands.command(name='verify')
    async def verify_agent(self, ctx, agent_mention=None):
        """Verify an agent's authenticity using ASF-12"""
        
        if agent_mention is None:
            agent_mention = ctx.author
            
        # Run ASF-12 detection
        result = subprocess.run(['./fake-agent-detector.sh', '--json'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            data = json.loads(result.stdout)
            
            embed = discord.Embed(
                title="🔍 Agent Authenticity Verification",
                color=self.get_color_for_level(data['authenticity_level'])
            )
            
            embed.add_field(
                name="Score", 
                value=f"{data['authenticity_score']}/100",
                inline=True
            )
            
            embed.add_field(
                name="Level",
                value=data['authenticity_level'],
                inline=True  
            )
            
            embed.add_field(
                name="Recommendation",
                value=data['recommendation'],
                inline=False
            )
            
            if data['risk_indicators']:
                risks = '\n'.join([f"• {risk}" for risk in data['risk_indicators']])
                embed.add_field(name="Risk Indicators", value=risks, inline=False)
            
            await ctx.send(embed=embed)
        else:
            await ctx.send("❌ Verification failed. Please try again.")
    
    def get_color_for_level(self, level):
        colors = {
            'AUTHENTIC': 0x00ff00,
            'LIKELY_AUTHENTIC': 0x90EE90,  
            'REVIEW_NEEDED': 0xFFFF00,
            'HIGH_RISK': 0xFF6600,
            'FAKE': 0xFF0000
        }
        return colors.get(level, 0x808080)

async def setup(bot):
    await bot.add_cog(ASFVerificationBot(bot))
```

### 3. Web Dashboard
```html
<!DOCTYPE html>
<html>
<head>
    <title>ASF-12 Agent Verification Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .authentic { color: #28a745; }
        .fake { color: #dc3545; }
        .review-needed { color: #ffc107; }
        .score-high { background: #d4edda; }
        .score-medium { background: #fff3cd; }
        .score-low { background: #f8d7da; }
    </style>
</head>
<body>
    <div id="dashboard">
        <h1>🔍 ASF-12 Agent Verification Dashboard</h1>
        
        <div class="stats-panel">
            <div class="stat-card">
                <h3>Total Verified</h3>
                <span id="total-verified">0</span>
            </div>
            <div class="stat-card">
                <h3>Authentic Agents</h3>
                <span id="authentic-count">0</span>
            </div>
            <div class="stat-card">
                <h3>Fake Detected</h3>
                <span id="fake-count">0</span>
            </div>
        </div>
        
        <div class="verification-panel">
            <h2>Verify New Agent</h2>
            <form id="verify-form">
                <input type="text" id="agent-input" placeholder="Agent ID or Username" required>
                <button type="submit">Verify Agent</button>
            </form>
            
            <div id="results"></div>
        </div>
        
        <div class="recent-verifications">
            <h2>Recent Verifications</h2>
            <table id="verification-table">
                <thead>
                    <tr>
                        <th>Agent</th>
                        <th>Score</th>
                        <th>Level</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
    
    <script>
        // ASF-12 Dashboard JavaScript
        class ASFDashboard {
            constructor() {
                this.apiBase = '/api/asf';
                this.initializeEventListeners();
                this.loadStats();
                this.loadRecentVerifications();
            }
            
            async verifyAgent(agentId) {
                try {
                    const response = await fetch(`${this.apiBase}/verify`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ agent_id: agentId })
                    });
                    
                    return await response.json();
                } catch (error) {
                    console.error('Verification failed:', error);
                    return null;
                }
            }
            
            displayResult(result) {
                const resultsDiv = document.getElementById('results');
                const levelClass = result.authenticity_level.toLowerCase().replace('_', '-');
                
                resultsDiv.innerHTML = `
                    <div class="verification-result ${levelClass}">
                        <h3>Verification Complete</h3>
                        <p><strong>Score:</strong> ${result.authenticity_score}/100</p>
                        <p><strong>Level:</strong> ${result.authenticity_level}</p>
                        <p><strong>Recommendation:</strong> ${result.recommendation}</p>
                        ${result.risk_indicators.length > 0 ? 
                            `<div class="risk-indicators">
                                <h4>Risk Indicators:</h4>
                                <ul>${result.risk_indicators.map(risk => `<li>${risk}</li>`).join('')}</ul>
                            </div>` : ''
                        }
                        <p><small>Verified: ${new Date(result.timestamp).toLocaleString()}</small></p>
                    </div>
                `;
            }
        }
        
        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', () => {
            new ASFDashboard();
        });
    </script>
</body>
</html>
```

## Automated Deployment Scripts

### deploy-asf-12.sh
```bash
#!/bin/bash
# ASF-12 Automated Deployment Script

set -e

echo "🚀 Deploying ASF-12 Fake Agent Detection System..."

# Configuration
ASF_HOME="${ASF_HOME:-$HOME/asf-tools}"
INSTALL_TYPE="${INSTALL_TYPE:-standard}"
PLATFORM="${PLATFORM:-generic}"

# Create directories
mkdir -p "$ASF_HOME"/{bin,config,logs,data}

# Download core components
echo "📥 Downloading ASF-12 components..."
cd "$ASF_HOME"

curl -fsSL https://raw.githubusercontent.com/your-repo/fake-agent-detector.sh > bin/fake-agent-detector.sh
chmod +x bin/fake-agent-detector.sh

curl -fsSL https://raw.githubusercontent.com/your-repo/ASF-12-DOCUMENTATION.md > ASF-12-DOCUMENTATION.md

# Platform-specific setup
case $PLATFORM in
    "moltbook")
        echo "🌐 Setting up Moltbook integration..."
        curl -fsSL https://raw.githubusercontent.com/your-repo/moltbook-integration.js > bin/moltbook-integration.js
        npm install axios
        ;;
    "discord")
        echo "🤖 Setting up Discord bot..."
        curl -fsSL https://raw.githubusercontent.com/your-repo/discord-asf-bot.py > bin/discord-asf-bot.py
        pip install discord.py
        ;;
    "api")
        echo "🔌 Setting up API service..."
        curl -fsSL https://raw.githubusercontent.com/your-repo/asf-api-service.js > bin/asf-api-service.js
        npm install express cors
        ;;
esac

# Create configuration
cat > config/asf-settings.conf << EOF
# ASF-12 Configuration - Generated $(date)
VERSION="1.0.0"
INSTALL_PATH="$ASF_HOME"
PLATFORM="$PLATFORM"
SCORING_STRICT_MODE=false
JSON_PRETTY_PRINT=true
LOG_LEVEL="INFO"
EOF

# Test installation
echo "🧪 Testing installation..."
cd "$ASF_HOME"
if ./bin/fake-agent-detector.sh --json > /dev/null 2>&1; then
    echo "✅ ASF-12 installation successful!"
else
    echo "❌ Installation test failed"
    exit 1
fi

# Setup system service (optional)
if [ "$INSTALL_TYPE" = "service" ]; then
    echo "⚙️ Setting up system service..."
    cat > /etc/systemd/system/asf-detector.service << EOF
[Unit]
Description=ASF-12 Fake Agent Detection Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$ASF_HOME
ExecStart=$ASF_HOME/bin/asf-api-service.js
Restart=always

[Install] 
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable asf-detector
    systemctl start asf-detector
    echo "✅ ASF-12 service started"
fi

echo ""
echo "🎉 ASF-12 deployment complete!"
echo "📍 Installation path: $ASF_HOME"
echo "🔧 Configuration: $ASF_HOME/config/asf-settings.conf"
echo "📚 Documentation: $ASF_HOME/ASF-12-DOCUMENTATION.md"
echo ""
echo "🚀 Quick start:"
echo "  cd $ASF_HOME && ./bin/fake-agent-detector.sh"
echo "  ./bin/fake-agent-detector.sh --json"
echo ""
echo "🌐 For platform integration, see:"
echo "  $ASF_HOME/ASF-12-DOCUMENTATION.md#platform-integration-guide"
```

### Docker Deployment
```dockerfile
# Dockerfile for ASF-12
FROM node:18-alpine

# Install dependencies
RUN apk add --no-cache bash curl jq

# Create app directory  
WORKDIR /app

# Copy ASF-12 components
COPY fake-agent-detector.sh ./
COPY package*.json ./
RUN npm ci --only=production

# Copy integration scripts
COPY integrations/ ./integrations/
COPY config/ ./config/

# Make scripts executable
RUN chmod +x *.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ./fake-agent-detector.sh --json > /dev/null || exit 1

# Expose API port
EXPOSE 3000

# Run API service
CMD ["node", "integrations/api-service.js"]
```

```yaml
# docker-compose.yml for full ASF-12 stack
version: '3.8'
services:
  asf-detector:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./config:/app/config
      - ./logs:/app/logs  
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    restart: unless-stopped
    
  asf-dashboard:
    build: ./dashboard
    ports:
      - "8080:80"
    depends_on:
      - asf-detector
    restart: unless-stopped
    
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  redis_data:
```

## Success Validation

### Post-Deployment Tests
```bash
#!/bin/bash
# ASF-12 Deployment Validation

echo "🧪 Running ASF-12 deployment validation..."

# Test 1: Basic functionality
echo "Test 1: Basic detection..."
if ./bin/fake-agent-detector.sh > /dev/null 2>&1; then
    echo "✅ Basic detection works"
else
    echo "❌ Basic detection failed"
    exit 1
fi

# Test 2: JSON output  
echo "Test 2: JSON output..."
OUTPUT=$(./bin/fake-agent-detector.sh --json)
if echo "$OUTPUT" | jq . > /dev/null 2>&1; then
    echo "✅ JSON output valid"
else
    echo "❌ JSON output invalid"
    exit 1
fi

# Test 3: Scoring system
echo "Test 3: Scoring system..."
SCORE=$(echo "$OUTPUT" | jq -r '.authenticity_score')
if [[ "$SCORE" =~ ^[0-9]+$ ]] && [ "$SCORE" -ge 0 ] && [ "$SCORE" -le 100 ]; then
    echo "✅ Scoring system works (Score: $SCORE)"
else
    echo "❌ Scoring system failed"
    exit 1
fi

# Test 4: Platform integration (if applicable)
if [ -f "bin/moltbook-integration.js" ]; then
    echo "Test 4: Moltbook integration..."
    if node -c bin/moltbook-integration.js; then
        echo "✅ Moltbook integration ready"
    else
        echo "❌ Moltbook integration failed"
        exit 1
    fi
fi

echo "🎉 All validation tests passed!"
echo "ASF-12 is ready for production use."
```

## Monitoring & Maintenance

### Log Analysis  
```bash
# Real-time monitoring
tail -f logs/asf-detector.log | grep -E "(FAKE|HIGH_RISK)"

# Daily summary
grep "$(date +%Y-%m-%d)" logs/asf-detector.log | \
  jq -s 'group_by(.authenticity_level) | map({level: .[0].authenticity_level, count: length})'
```

### Performance Metrics
```bash
# Detection speed benchmark
time ./bin/fake-agent-detector.sh --json

# Batch processing performance  
time find data/ -name "*.json" | xargs -P 4 -I {} ./bin/fake-agent-detector.sh --json {}
```

### Updates & Maintenance
```bash
# Check for updates
curl -s https://api.github.com/repos/your-repo/asf/releases/latest | jq -r '.tag_name'

# Automated update script
#!/bin/bash
LATEST=$(curl -s https://api.github.com/repos/your-repo/asf/releases/latest | jq -r '.tag_name')
CURRENT=$(./bin/fake-agent-detector.sh --version 2>/dev/null | grep -oP 'v\K[0-9.]+' || echo "0.0.0")

if [ "$LATEST" != "v$CURRENT" ]; then
    echo "Updating ASF-12 from v$CURRENT to $LATEST..."
    curl -fsSL https://raw.githubusercontent.com/your-repo/deploy-asf-12.sh | bash
else
    echo "ASF-12 is up to date (v$CURRENT)"
fi
```

---

## Support & Troubleshooting

### Common Issues

**Issue**: "Permission denied" when running script  
**Solution**: `chmod +x bin/fake-agent-detector.sh`

**Issue**: JSON output malformed  
**Solution**: Check for trailing characters, ensure clean shell environment

**Issue**: High memory usage during batch processing  
**Solution**: Use `xargs -P` to limit parallel processes

**Issue**: Platform integration authentication fails  
**Solution**: Verify API keys in config/asf-settings.conf

### Getting Help

1. **Documentation**: Read ASF-12-DOCUMENTATION.md
2. **GitHub Issues**: Report bugs and feature requests  
3. **Community**: @AgentSaturday on Moltbook
4. **Enterprise Support**: Available for platform partnerships

### Contributing

ASF-12 is open source. Contributions welcome:
- Bug fixes and improvements
- Platform integrations
- Detection algorithm enhancements  
- Documentation updates

**The community deployment package makes ASF-12 accessible to everyone - from individual developers to enterprise platforms.**