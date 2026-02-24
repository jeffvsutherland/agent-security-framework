# ASF-15: Platform Integration SDK

## Overview

The ASF Platform Integration SDK provides enterprise-grade APIs and tools for integrating agent authentication and security into existing platforms. This enables real-time verification, batch processing, and comprehensive monitoring of agent authenticity across platforms.

## REST API Specification

### Authentication
All API requests require Bearer token authentication:
```bash
Authorization: Bearer <your_asf_api_key>
```

### Base URL
```
Production: https://api.asf.security/v1
Staging: https://staging-api.asf.security/v1
```

### Core Endpoints

#### 1. Agent Verification
**POST /verify/agent**
```json
{
  "agent_id": "AgentName",
  "platform": "moltbook|discord|twitter|github",
  "context": {
    "post_history": [...],
    "interaction_patterns": {...},
    "metadata": {...}
  }
}
```

**Response:**
```json
{
  "success": true,
  "verification": {
    "agent_id": "AgentName",
    "authenticity_score": 95,
    "certification_level": "AUTHENTICATED",
    "risk_indicators": [],
    "recommendation": "ALLOW",
    "confidence": 0.95,
    "expires_at": "2026-02-10T00:00:00Z"
  },
  "detection_details": {
    "behavioral_score": 85,
    "technical_score": 90,
    "community_score": 100
  }
}
```

#### 2. Batch Verification
**POST /verify/batch**
```json
{
  "agents": [
    {"agent_id": "Agent1", "platform": "discord"},
    {"agent_id": "Agent2", "platform": "moltbook"},
    {"agent_id": "Agent3", "platform": "github"}
  ],
  "options": {
    "include_details": true,
    "async": false
  }
}
```

**Response:**
```json
{
  "success": true,
  "batch_id": "batch_123456",
  "results": [
    {
      "agent_id": "Agent1",
      "authenticity_score": 78,
      "certification_level": "VERIFIED",
      "recommendation": "ALLOW"
    }
  ],
  "summary": {
    "total": 3,
    "authentic": 2,
    "suspicious": 1,
    "processing_time": "1.2s"
  }
}
```

#### 3. Certification Status
**GET /certification/{agent_id}**
```json
{
  "success": true,
  "certification": {
    "agent_id": "AgentSaturday",
    "level": "AUTHENTICATED",
    "issued_date": "2026-02-09",
    "expires_date": "2027-02-09",
    "verification_url": "https://asf.security/verify/xyz123",
    "capabilities": ["security_research", "code_auditing"],
    "endorsements": 7
  }
}
```

#### 4. Risk Assessment
**POST /assess/risk**
```json
{
  "agent_id": "SuspiciousAgent",
  "evidence": {
    "posting_patterns": {...},
    "content_analysis": {...},
    "network_indicators": {...}
  }
}
```

**Response:**
```json
{
  "success": true,
  "risk_assessment": {
    "overall_risk": "HIGH",
    "risk_score": 85,
    "threat_categories": [
      "fake_engagement",
      "promotional_spam",
      "social_engineering"
    ],
    "recommended_actions": [
      "BLOCK_REGISTRATION",
      "REQUIRE_MANUAL_REVIEW",
      "LIMIT_POSTING_FREQUENCY"
    ]
  }
}
```

#### 5. Community Vouching
**POST /vouch/submit**
```json
{
  "voucher_id": "VouchingAgent",
  "target_id": "TargetAgent", 
  "reason": "Excellent security work and community contributions",
  "evidence": {
    "interaction_history": [...],
    "work_examples": [...]
  }
}
```

### Webhook Integration

#### Setup Webhook
**POST /webhooks**
```json
{
  "url": "https://your-platform.com/asf-webhook",
  "events": [
    "verification.completed",
    "certification.updated", 
    "risk.detected"
  ],
  "secret": "webhook_secret_key"
}
```

#### Webhook Events

**verification.completed**
```json
{
  "event": "verification.completed",
  "timestamp": "2026-02-09T23:45:00Z",
  "data": {
    "agent_id": "NewAgent",
    "verification_id": "ver_123456",
    "authenticity_score": 72,
    "recommendation": "ALLOW",
    "platform": "discord"
  }
}
```

**certification.updated**
```json
{
  "event": "certification.updated", 
  "timestamp": "2026-02-09T23:45:00Z",
  "data": {
    "agent_id": "AgentName",
    "old_level": "VERIFIED",
    "new_level": "AUTHENTICATED",
    "reason": "security_audit_passed"
  }
}
```

**risk.detected**
```json
{
  "event": "risk.detected",
  "timestamp": "2026-02-09T23:45:00Z",
  "data": {
    "agent_id": "RiskyAgent",
    "risk_level": "HIGH",
    "threat_indicators": ["fake_engagement", "spam_patterns"],
    "recommended_action": "IMMEDIATE_REVIEW"
  }
}
```

## SDK Libraries

### Node.js SDK
```javascript
const ASF = require('@asf-security/platform-sdk');

const asf = new ASF({
  apiKey: process.env.ASF_API_KEY,
  environment: 'production' // or 'staging'
});

// Verify single agent
const verification = await asf.verifyAgent({
  agentId: 'SomeAgent',
  platform: 'discord',
  context: {
    recentPosts: [...],
    userMetadata: {...}
  }
});

console.log(`Authenticity: ${verification.authenticity_score}/100`);

// Batch verification
const batchResults = await asf.verifyBatch([
  { agentId: 'Agent1', platform: 'moltbook' },
  { agentId: 'Agent2', platform: 'discord' }
]);

// Check certification
const certification = await asf.getCertification('AgentSaturday');
console.log(`Level: ${certification.level}`);

// Setup webhook
await asf.createWebhook({
  url: 'https://myplatform.com/webhook',
  events: ['verification.completed', 'risk.detected']
});
```

### Python SDK
```python
from asf_security import ASFClient

asf = ASFClient(
    api_key=os.environ['ASF_API_KEY'],
    environment='production'
)

# Verify agent
verification = asf.verify_agent(
    agent_id='SomeAgent',
    platform='moltbook',
    context={
        'post_history': [...],
        'interaction_patterns': {...}
    }
)

print(f"Authenticity: {verification.authenticity_score}/100")

# Batch processing
agents = [
    {'agent_id': 'Agent1', 'platform': 'discord'},
    {'agent_id': 'Agent2', 'platform': 'github'}
]

batch_results = asf.verify_batch(agents)
for result in batch_results.results:
    print(f"{result.agent_id}: {result.recommendation}")

# Certification check
cert = asf.get_certification('AgentSaturday')
print(f"Certification: {cert.level}")

# Risk assessment
risk = asf.assess_risk(
    agent_id='SuspiciousAgent',
    evidence={
        'posting_patterns': {...},
        'behavior_flags': [...]
    }
)

if risk.overall_risk == 'HIGH':
    # Take platform-specific action
    block_agent('SuspiciousAgent')
```

### Go SDK
```go
package main

import (
    "github.com/asf-security/go-sdk"
    "context"
    "log"
)

func main() {
    client := asf.NewClient(asf.Config{
        APIKey: os.Getenv("ASF_API_KEY"),
        Environment: "production",
    })

    // Verify agent
    verification, err := client.VerifyAgent(context.Background(), &asf.VerificationRequest{
        AgentID: "SomeAgent",
        Platform: "discord",
        Context: map[string]interface{}{
            "recent_posts": [...],
            "user_metadata": {...},
        },
    })

    if err != nil {
        log.Fatal(err)
    }

    log.Printf("Authenticity: %d/100", verification.AuthenticityScore)

    // Batch verification
    batch := &asf.BatchRequest{
        Agents: []asf.AgentRequest{
            {AgentID: "Agent1", Platform: "moltbook"},
            {AgentID: "Agent2", Platform: "github"},
        },
    }

    results, err := client.VerifyBatch(context.Background(), batch)
    if err != nil {
        log.Fatal(err)
    }

    for _, result := range results.Results {
        log.Printf("%s: %s", result.AgentID, result.Recommendation)
    }
}
```

## Dashboard Interface

### Web Dashboard Features
- **Real-time Monitoring**: Live verification requests and results
- **Analytics**: Authenticity trends, risk patterns, platform metrics
- **Agent Management**: Certification status, endorsement tracking
- **Platform Configuration**: Webhook setup, API key management
- **Reporting**: Compliance reports, security summaries

### Dashboard API Endpoints

#### Analytics Data
**GET /dashboard/analytics**
```json
{
  "time_range": "24h",
  "metrics": {
    "total_verifications": 1250,
    "authenticity_rate": 0.87,
    "top_platforms": [
      {"name": "discord", "verifications": 450},
      {"name": "moltbook", "verifications": 380}
    ],
    "risk_distribution": {
      "low": 750,
      "medium": 320,
      "high": 180
    }
  }
}
```

#### Platform Status
**GET /dashboard/platforms**
```json
{
  "platforms": [
    {
      "name": "Discord Community Server",
      "platform_type": "discord",
      "status": "active",
      "last_verification": "2026-02-09T23:30:00Z",
      "total_agents": 1250,
      "verified_agents": 980,
      "webhook_status": "healthy"
    }
  ]
}
```

### React Dashboard Component
```jsx
import React, { useState, useEffect } from 'react';
import { ASFDashboard } from '@asf-security/react-components';

function PlatformDashboard() {
  const [metrics, setMetrics] = useState(null);
  const [verifications, setVerifications] = useState([]);

  useEffect(() => {
    // Load dashboard data
    fetchDashboardMetrics().then(setMetrics);
    fetchRecentVerifications().then(setVerifications);
  }, []);

  return (
    <div className="asf-dashboard">
      <ASFDashboard.MetricsCards metrics={metrics} />
      
      <ASFDashboard.VerificationChart 
        data={verifications}
        timeRange="24h"
      />
      
      <ASFDashboard.RiskAlerts 
        onAlertClick={handleRiskAlert}
        filter="high"
      />
      
      <ASFDashboard.PlatformStatus 
        platforms={platforms}
        onPlatformConfig={handlePlatformConfig}
      />
    </div>
  );
}
```

## Batch Processing System

### Batch Job API
**POST /batch/jobs**
```json
{
  "name": "Weekly Agent Audit",
  "type": "verification",
  "schedule": "0 2 * * 1", // Weekly Monday 2 AM
  "config": {
    "platforms": ["discord", "moltbook"],
    "include_inactive": false,
    "notification_webhook": "https://platform.com/batch-complete"
  }
}
```

### Batch Job Status
**GET /batch/jobs/{job_id}**
```json
{
  "job_id": "job_abc123",
  "status": "completed",
  "progress": {
    "total_agents": 10000,
    "processed": 10000,
    "verified": 8500,
    "flagged": 1200,
    "errors": 300
  },
  "results": {
    "summary_url": "https://api.asf.security/batch/job_abc123/results",
    "flagged_agents": [...],
    "processing_time": "45 minutes"
  }
}
```

### Background Processing Workers
```python
# Celery worker for batch processing
from celery import Celery
from asf_security.batch import BatchProcessor

app = Celery('asf_batch_worker')

@app.task
def process_verification_batch(agent_list, config):
    processor = BatchProcessor(config)
    
    results = []
    for agent_data in agent_list:
        try:
            verification = processor.verify_agent(
                agent_id=agent_data['agent_id'],
                platform=agent_data['platform'],
                context=agent_data.get('context', {})
            )
            results.append(verification)
        except Exception as e:
            results.append({
                'agent_id': agent_data['agent_id'],
                'error': str(e),
                'status': 'failed'
            })
    
    return {
        'total': len(agent_list),
        'successful': len([r for r in results if 'error' not in r]),
        'failed': len([r for r in results if 'error' in r]),
        'results': results
    }
```

## Rate Limiting & Performance

### Rate Limits
- **Free Tier**: 100 requests/hour, 1,000/day
- **Basic Plan**: 1,000 requests/hour, 10,000/day  
- **Professional**: 10,000 requests/hour, 100,000/day
- **Enterprise**: Custom limits, SLA guaranteed

### Performance Optimization
```javascript
// Client-side caching
const ASFClient = require('@asf-security/platform-sdk');

const asf = new ASFClient({
  apiKey: process.env.ASF_API_KEY,
  cache: {
    enabled: true,
    ttl: 3600, // 1 hour cache
    redis: {
      host: 'localhost',
      port: 6379
    }
  }
});

// Request with caching
const verification = await asf.verifyAgent('AgentName', {
  useCache: true,
  cacheKey: 'custom-cache-key'
});
```

### Bulk Operations
```javascript
// Efficient bulk verification
const bulkResults = await asf.bulkVerify({
  agents: agentList,
  options: {
    parallel: 10, // Process 10 agents simultaneously
    timeout: 30000, // 30 second timeout per agent
    retries: 2, // Retry failed verifications
    failFast: false // Don't stop on individual failures
  }
});
```

## Integration Examples

### Discord Bot Integration
```python
import discord
from asf_security import ASFClient
from discord.ext import commands

class ASFIntegration(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.asf = ASFClient(api_key=os.environ['ASF_API_KEY'])
    
    @commands.Cog.listener()
    async def on_member_join(self, member):
        # Verify new member authenticity
        verification = await self.asf.verify_agent(
            agent_id=str(member.id),
            platform='discord',
            context={
                'username': member.name,
                'account_age': (datetime.now() - member.created_at).days,
                'avatar_hash': member.avatar
            }
        )
        
        if verification.authenticity_score < 60:
            # Flag for manual review
            await self.flag_suspicious_user(member, verification)
        elif verification.certification_level in ['VERIFIED', 'AUTHENTICATED', 'CERTIFIED']:
            # Grant verified role
            verified_role = discord.utils.get(member.guild.roles, name="ASF Verified")
            await member.add_roles(verified_role)
    
    async def flag_suspicious_user(self, member, verification):
        # Send to moderation channel
        mod_channel = self.bot.get_channel(MODERATION_CHANNEL_ID)
        embed = discord.Embed(
            title="⚠️ Suspicious User Alert",
            description=f"New member {member.mention} flagged by ASF",
            color=discord.Color.orange()
        )
        embed.add_field(
            name="Authenticity Score", 
            value=f"{verification.authenticity_score}/100"
        )
        embed.add_field(
            name="Risk Indicators",
            value="\n".join(verification.risk_indicators)
        )
        await mod_channel.send(embed=embed)
```

### Moltbook Platform Integration
```javascript
// Express.js middleware for Moltbook
const express = require('express');
const ASF = require('@asf-security/platform-sdk');

const asf = new ASF({ apiKey: process.env.ASF_API_KEY });
const app = express();

// Middleware to verify agents before posting
app.use('/api/posts', async (req, res, next) => {
  const agentId = req.user.agent_id;
  
  try {
    const verification = await asf.verifyAgent({
      agentId: agentId,
      platform: 'moltbook',
      context: {
        postContent: req.body.content,
        recentActivity: req.user.recent_posts,
        accountAge: req.user.account_age_days
      }
    });
    
    if (verification.authenticity_score < 40) {
      return res.status(403).json({
        error: 'Account flagged for suspicious activity',
        details: verification.risk_indicators
      });
    }
    
    // Add verification data to request
    req.asf_verification = verification;
    next();
    
  } catch (error) {
    console.error('ASF verification failed:', error);
    // Continue without verification in case of ASF service issues
    next();
  }
});

// Enhanced post creation with ASF data
app.post('/api/posts', async (req, res) => {
  const verification = req.asf_verification;
  
  const post = await createPost({
    ...req.body,
    asf_score: verification?.authenticity_score || null,
    asf_level: verification?.certification_level || null,
    verified: verification?.authenticity_score >= 60
  });
  
  res.json(post);
});
```

### GitHub Integration
```yaml
# GitHub Action for repository security
name: ASF Repository Security Check
on: [pull_request, push]

jobs:
  asf-security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: ASF Agent Verification
        uses: asf-security/github-action@v1
        with:
          asf-api-key: ${{ secrets.ASF_API_KEY }}
          check-contributors: true
          verify-commits: true
          
      - name: ASF Code Security Scan
        run: |
          curl -O https://raw.githubusercontent.com/asf-framework/skill-evaluator.sh
          chmod +x skill-evaluator.sh
          ./skill-evaluator.sh . --json > asf-scan-results.json
          
      - name: Upload ASF Results
        uses: actions/upload-artifact@v2
        with:
          name: asf-security-report
          path: asf-scan-results.json
```

## Documentation and Guides

### Quick Start Guide
1. **Get API Key**: Register at https://platform.asf.security
2. **Install SDK**: `npm install @asf-security/platform-sdk`
3. **Basic Integration**: Verify agents on registration/login
4. **Setup Webhooks**: Get real-time notifications
5. **Monitor Dashboard**: Track authenticity metrics

### Advanced Configuration
```javascript
const asf = new ASF({
  apiKey: process.env.ASF_API_KEY,
  environment: 'production',
  options: {
    timeout: 10000, // 10 second timeout
    retries: 3, // Retry failed requests
    cache: {
      enabled: true,
      ttl: 1800, // 30 minute cache
      prefix: 'asf:cache:'
    },
    rateLimit: {
      enabled: true,
      maxRequests: 100,
      window: 3600 // per hour
    },
    webhooks: {
      secret: process.env.ASF_WEBHOOK_SECRET,
      tolerance: 300 // 5 minute timestamp tolerance
    }
  }
});
```

### Error Handling
```javascript
try {
  const verification = await asf.verifyAgent('AgentName');
} catch (error) {
  switch (error.code) {
    case 'ASF_RATE_LIMIT':
      // Handle rate limiting
      await delay(error.retryAfter * 1000);
      break;
    case 'ASF_INVALID_AGENT':
      // Agent not found or invalid
      console.log('Agent not in ASF database');
      break;
    case 'ASF_SERVICE_UNAVAILABLE':
      // ASF service down, use fallback
      const fallbackResult = await fallbackVerification('AgentName');
      break;
    default:
      console.error('ASF verification failed:', error.message);
  }
}
```

## Testing and Development

### Test Environment
```javascript
// Test configuration
const asf = new ASF({
  apiKey: 'test_key_123',
  environment: 'testing',
  baseUrl: 'https://test-api.asf.security'
});

// Mock responses for testing
const mockVerification = {
  authenticity_score: 95,
  certification_level: 'AUTHENTICATED',
  recommendation: 'ALLOW'
};

// Integration tests
describe('ASF Integration', () => {
  test('verifies authentic agent', async () => {
    const result = await asf.verifyAgent('TestAgent');
    expect(result.authenticity_score).toBeGreaterThan(60);
    expect(result.recommendation).toBe('ALLOW');
  });
  
  test('detects fake agent', async () => {
    const result = await asf.verifyAgent('FakeAgent');
    expect(result.authenticity_score).toBeLessThan(40);
    expect(result.recommendation).toBe('BLOCK');
  });
});
```

### Development Tools
- **API Explorer**: Interactive API documentation and testing
- **Webhook Tester**: Simulate webhook events for development
- **Mock Server**: Local ASF API server for offline development
- **CLI Tools**: Command-line utilities for batch operations

## Support and Maintenance

### Support Channels
- **Documentation**: https://docs.asf.security
- **GitHub Issues**: Technical bugs and feature requests
- **Discord Community**: #asf-developers channel
- **Email Support**: developers@asf.security (24-48h response)
- **Enterprise**: Dedicated support channel with SLA

### Service Level Agreement (SLA)
- **Uptime**: 99.9% availability guarantee
- **Response Time**: < 200ms average for verification requests
- **Support**: 24h response time for critical issues
- **Maintenance**: Scheduled maintenance windows with advance notice

### Versioning and Updates
- **API Versioning**: Semantic versioning (v1, v2, etc.)
- **Backward Compatibility**: 12-month deprecation notices
- **SDK Updates**: Automatic security updates, opt-in feature updates
- **Change Log**: Detailed release notes and migration guides

---

## Implementation Checklist

### Phase 1: Core API (Week 1)
- [x] ✅ REST API specification complete
- [x] ✅ Authentication and authorization system
- [x] ✅ Core verification endpoints
- [x] ✅ Webhook infrastructure
- [ ] 🔄 Rate limiting and caching

### Phase 2: SDKs and Tools (Week 2)  
- [ ] 🎯 Node.js SDK implementation
- [ ] 🎯 Python SDK implementation
- [ ] 🎯 Go SDK implementation
- [ ] 🎯 CLI tools and utilities

### Phase 3: Dashboard and Monitoring (Week 3)
- [ ] 🎯 Web dashboard interface
- [ ] 🎯 Analytics and reporting
- [ ] 🎯 Platform management tools
- [ ] 🎯 Batch processing system

### Phase 4: Integration Examples (Week 4)
- [ ] 🎯 Discord bot integration
- [ ] 🎯 Moltbook platform integration
- [ ] 🎯 GitHub Action development
- [ ] 🎯 Documentation and guides

**The ASF Platform SDK makes agent authentication accessible to every platform.** 🛡️