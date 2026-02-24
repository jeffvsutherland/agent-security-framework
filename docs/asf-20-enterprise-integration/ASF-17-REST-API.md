# ASF-17: Enterprise REST API

**Agent Security Framework Enterprise Integration Package**  
**Component:** Platform-Agnostic Agent Verification API

## Overview

Enterprise-grade REST API that provides agent verification services for any platform or application. Enables custom integrations, third-party platform connections, and large-scale agent security deployments.

## Business Case

### API Economy Opportunity
- **Platform integrations:** Connect to any messaging platform, website, or application
- **Third-party partnerships:** Enable security vendors to integrate ASF capabilities
- **White-label solutions:** Power other companies' agent security products
- **Revenue model:** API call-based pricing + enterprise licenses ($500-5000/month)

### Target Customers
- **API platforms:** Twilio, Discord, Slack competitors
- **Security vendors:** Companies building AI security products
- **Enterprise developers:** Internal tools and custom integrations
- **Platform operators:** Websites and services hosting AI agents

## Technical Implementation

### API Architecture
```
Client Application → ASF REST API → Authentication → fake-agent-detector.sh → Response + Logging
                                 ↓
                    Rate limiting + Analytics + Enterprise dashboard
```

### Core Endpoints

#### 1. Agent Verification
```http
POST /api/v1/verify
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "agent_id": "string",
  "platform": "discord|slack|web|custom",
  "context": {
    "message_history": ["array of recent messages"],
    "metadata": {"platform-specific data"},
    "timestamp": "ISO 8601 datetime"
  },
  "options": {
    "include_explanation": true,
    "detailed_analysis": true,
    "custom_rules": ["rule_id_1", "rule_id_2"]
  }
}
```

**Response:**
```json
{
  "success": true,
  "verification_id": "ver_abc123",
  "timestamp": "2026-02-11T15:36:00Z",
  "agent_verification": {
    "risk_level": "LOW|MEDIUM|HIGH",
    "trust_score": 85,
    "confidence": 0.92,
    "classification": "AUTHENTIC|SUSPICIOUS|FAKE",
    "compliance_status": "COMPLIANT|NON_COMPLIANT",
    "analysis": {
      "behavioral_indicators": {
        "consistency_score": 0.88,
        "response_patterns": "NATURAL",
        "temporal_analysis": "CONSISTENT"
      },
      "technical_indicators": {
        "api_signatures": "VALID",
        "rate_limiting_behavior": "NORMAL",
        "metadata_consistency": "VERIFIED"
      },
      "content_analysis": {
        "language_patterns": "AUTHENTIC",
        "knowledge_consistency": "HIGH",
        "hallucination_indicators": "NONE"
      }
    },
    "explanation": "Agent exhibits consistent behavioral patterns typical of authentic AI assistants...",
    "recommendations": [
      "Continue monitoring for behavioral changes",
      "Verify API credentials regularly"
    ]
  },
  "rate_limit": {
    "remaining_calls": 950,
    "reset_time": "2026-02-11T16:00:00Z",
    "tier": "enterprise"
  }
}
```

#### 2. Batch Verification
```http
POST /api/v1/batch-verify
Authorization: Bearer {api_key}

{
  "agents": [
    {
      "agent_id": "agent_1",
      "platform": "discord",
      "context": {...}
    },
    {
      "agent_id": "agent_2", 
      "platform": "slack",
      "context": {...}
    }
  ],
  "options": {
    "priority": "normal|high",
    "webhook_url": "https://yourapp.com/webhook"
  }
}
```

#### 3. Historical Analysis
```http
GET /api/v1/agent/{agent_id}/history
Authorization: Bearer {api_key}

Query Parameters:
- timeframe: 7d|30d|90d
- include_analysis: boolean
- format: json|csv
```

#### 4. Real-time Monitoring
```http
POST /api/v1/monitor/subscribe
Authorization: Bearer {api_key}

{
  "agent_ids": ["agent_1", "agent_2"],
  "platforms": ["discord", "slack"],
  "alert_thresholds": {
    "risk_level_change": true,
    "trust_score_drop": 20,
    "suspicious_activity": true
  },
  "webhook_url": "https://yourapp.com/alerts"
}
```

### API Implementation

#### Main API Server: `asf-api-server.js`
```javascript
const express = require('express');
const rateLimit = require('express-rate-limit');
const { body, param, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const { exec } = require('child_process');
const fs = require('fs');
const crypto = require('crypto');

class ASFAPIServer {
  constructor() {
    this.app = express();
    this.port = process.env.PORT || 3000;
    
    this.setupMiddleware();
    this.setupRoutes();
    this.setupErrorHandling();
  }
  
  setupMiddleware() {
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true }));
    
    // Rate limiting with tier-based limits
    const createRateLimit = (max, windowMs = 15 * 60 * 1000) => {
      return rateLimit({
        windowMs,
        max: (req) => {
          const tier = req.user?.tier || 'free';
          const limits = {
            'free': 100,
            'professional': 1000,
            'enterprise': 10000
          };
          return limits[tier] || max;
        },
        message: {
          error: 'Rate limit exceeded',
          tier: req => req.user?.tier,
          limit: req => req.rateLimit.limit
        }
      });
    };
    
    this.app.use('/api/', createRateLimit());
    
    // Authentication middleware
    this.app.use('/api/', this.authenticateAPI.bind(this));
  }
  
  async authenticateAPI(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Missing or invalid authorization header',
        required_format: 'Bearer {api_key}'
      });
    }
    
    const apiKey = authHeader.substring(7);
    
    try {
      const user = await this.validateAPIKey(apiKey);
      req.user = user;
      req.apiKey = apiKey;
      next();
    } catch (error) {
      res.status(401).json({
        error: 'Invalid API key',
        message: error.message
      });
    }
  }
  
  async validateAPIKey(apiKey) {
    // In production, this would query a database
    // For demo, we'll validate against known format
    const decoded = Buffer.from(apiKey, 'base64').toString();
    const [userId, tier, signature] = decoded.split(':');
    
    if (!userId || !tier || !signature) {
      throw new Error('Invalid API key format');
    }
    
    return {
      user_id: userId,
      tier: tier,
      permissions: this.getTierPermissions(tier)
    };
  }
  
  getTierPermissions(tier) {
    const permissions = {
      'free': ['verify'],
      'professional': ['verify', 'batch-verify', 'history'],
      'enterprise': ['verify', 'batch-verify', 'history', 'monitor', 'custom-rules', 'analytics']
    };
    
    return permissions[tier] || permissions['free'];
  }
  
  setupRoutes() {
    // Health check
    this.app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        version: '1.0.0',
        timestamp: new Date().toISOString()
      });
    });
    
    // Single agent verification
    this.app.post('/api/v1/verify',
      [
        body('agent_id').notEmpty().withMessage('Agent ID is required'),
        body('platform').isIn(['discord', 'slack', 'web', 'custom']).withMessage('Invalid platform'),
        body('context').optional().isObject().withMessage('Context must be an object')
      ],
      this.handleVerifyAgent.bind(this)
    );
    
    // Batch verification
    this.app.post('/api/v1/batch-verify',
      [
        body('agents').isArray({ min: 1, max: 100 }).withMessage('Agents array required (1-100 items)'),
        body('agents.*.agent_id').notEmpty().withMessage('Each agent must have an ID'),
        body('agents.*.platform').isIn(['discord', 'slack', 'web', 'custom']).withMessage('Invalid platform')
      ],
      this.handleBatchVerify.bind(this)
    );
    
    // Historical analysis
    this.app.get('/api/v1/agent/:agentId/history',
      [
        param('agentId').notEmpty().withMessage('Agent ID is required')
      ],
      this.handleAgentHistory.bind(this)
    );
    
    // Real-time monitoring setup
    this.app.post('/api/v1/monitor/subscribe',
      [
        body('agent_ids').isArray().withMessage('Agent IDs array required'),
        body('webhook_url').isURL().withMessage('Valid webhook URL required')
      ],
      this.handleMonitorSubscribe.bind(this)
    );
    
    // API usage analytics
    this.app.get('/api/v1/analytics/usage', this.handleUsageAnalytics.bind(this));
  }
  
  async handleVerifyAgent(req, res) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }
    
    const { agent_id, platform, context, options } = req.body;
    const verificationId = `ver_${crypto.randomUUID()}`;
    
    try {
      // Log API call for analytics
      await this.logAPICall(req.user.user_id, 'verify', req.body);
      
      // Prepare context file for ASF detector
      const contextFile = `/tmp/asf_context_${verificationId}.json`;
      const contextData = {
        agent_id,
        platform,
        context: context || {},
        timestamp: new Date().toISOString(),
        verification_id: verificationId
      };
      
      fs.writeFileSync(contextFile, JSON.stringify(contextData, null, 2));
      
      // Run ASF detection
      const command = `./fake-agent-detector.sh --json --api --context-file ${contextFile}`;
      
      const verification = await new Promise((resolve, reject) => {
        exec(command, { timeout: 30000 }, (error, stdout, stderr) => {
          // Cleanup
          fs.unlinkSync(contextFile);
          
          if (error) {
            reject(new Error(`ASF detection failed: ${error.message}`));
            return;
          }
          
          try {
            const result = JSON.parse(stdout);
            resolve({
              ...result,
              verification_id: verificationId,
              timestamp: new Date().toISOString()
            });
          } catch (e) {
            reject(new Error('Invalid response from ASF detector'));
          }
        });
      });
      
      // Add API-specific metadata
      const response = {
        success: true,
        verification_id: verificationId,
        timestamp: verification.timestamp,
        agent_verification: verification,
        rate_limit: {
          remaining_calls: req.rateLimit.remaining,
          reset_time: new Date(Date.now() + req.rateLimit.msBeforeNext).toISOString(),
          tier: req.user.tier
        }
      };
      
      res.json(response);
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Verification failed',
        message: error.message,
        verification_id: verificationId
      });
    }
  }
  
  async handleBatchVerify(req, res) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }
    
    if (!req.user.permissions.includes('batch-verify')) {
      return res.status(403).json({
        error: 'Batch verification requires Professional or Enterprise tier'
      });
    }
    
    const { agents, options } = req.body;
    const batchId = `batch_${crypto.randomUUID()}`;
    
    try {
      // For large batches, process asynchronously
      if (agents.length > 10 && options?.webhook_url) {
        this.processBatchAsync(batchId, agents, options, req.user);
        
        res.json({
          success: true,
          batch_id: batchId,
          status: 'processing',
          message: 'Batch verification started. Results will be sent to webhook.',
          estimated_completion: new Date(Date.now() + agents.length * 2000).toISOString()
        });
      } else {
        // Process synchronously for smaller batches
        const results = await this.processBatchSync(agents, req.user);
        
        res.json({
          success: true,
          batch_id: batchId,
          status: 'completed',
          results
        });
      }
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Batch verification failed',
        message: error.message,
        batch_id: batchId
      });
    }
  }
  
  async handleAgentHistory(req, res) {
    if (!req.user.permissions.includes('history')) {
      return res.status(403).json({
        error: 'Historical analysis requires Professional or Enterprise tier'
      });
    }
    
    const { agentId } = req.params;
    const { timeframe = '7d', include_analysis = true, format = 'json' } = req.query;
    
    try {
      const history = await this.getAgentHistory(agentId, timeframe, include_analysis);
      
      if (format === 'csv') {
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="agent_${agentId}_history.csv"`);
        res.send(this.convertToCSV(history));
      } else {
        res.json({
          success: true,
          agent_id: agentId,
          timeframe,
          history
        });
      }
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Failed to retrieve agent history',
        message: error.message
      });
    }
  }
}

module.exports = ASFAPIServer;
```

### Authentication & Security

#### API Key Management
```javascript
// API key generation (enterprise feature)
class APIKeyManager {
  generateAPIKey(userId, tier = 'free') {
    const payload = `${userId}:${tier}:${Date.now()}`;
    const signature = crypto
      .createHmac('sha256', process.env.API_SECRET)
      .update(payload)
      .digest('hex')
      .substring(0, 16);
    
    const apiKey = Buffer.from(`${payload}:${signature}`).toString('base64');
    return `asf_${apiKey}`;
  }
  
  revokeAPIKey(apiKey) {
    // Add to revocation list
    return this.addToRevocationList(apiKey);
  }
}
```

#### Rate Limiting Strategy
```javascript
const rateLimits = {
  free: {
    requests_per_hour: 100,
    batch_size_limit: 10,
    concurrent_requests: 1
  },
  professional: {
    requests_per_hour: 1000,
    batch_size_limit: 50,
    concurrent_requests: 5
  },
  enterprise: {
    requests_per_hour: 10000,
    batch_size_limit: 1000,
    concurrent_requests: 20
  }
};
```

### Enterprise Features

#### 1. Custom Rules Engine
```javascript
// Enterprise customers can define custom verification rules
app.post('/api/v1/custom-rules', requiresEnterprise, async (req, res) => {
  const { rule_name, conditions, actions } = req.body;
  
  const rule = await createCustomRule({
    user_id: req.user.user_id,
    rule_name,
    conditions, // Custom detection logic
    actions     // Custom response actions
  });
  
  res.json({ success: true, rule_id: rule.id });
});
```

#### 2. Real-time Webhooks
```javascript
// Webhook delivery for enterprise monitoring
class WebhookManager {
  async deliverWebhook(url, payload, retries = 3) {
    for (let i = 0; i < retries; i++) {
      try {
        const response = await fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-ASF-Signature': this.generateSignature(payload)
          },
          body: JSON.stringify(payload)
        });
        
        if (response.ok) return true;
        
      } catch (error) {
        console.error(`Webhook delivery attempt ${i + 1} failed:`, error);
      }
      
      await this.delay(Math.pow(2, i) * 1000); // Exponential backoff
    }
    
    return false;
  }
}
```

#### 3. Analytics Dashboard API
```javascript
app.get('/api/v1/analytics/usage', async (req, res) => {
  const usage = await getUsageAnalytics(req.user.user_id, req.query);
  
  res.json({
    period: req.query.period || '30d',
    metrics: {
      total_verifications: usage.total_verifications,
      api_calls: usage.api_calls,
      unique_agents: usage.unique_agents,
      accuracy_rate: usage.accuracy_rate,
      response_time_avg: usage.avg_response_time,
      error_rate: usage.error_rate
    },
    usage_trends: usage.daily_trends,
    top_platforms: usage.platform_breakdown
  });
});
```

## Business Model

### API Pricing Tiers

#### Free Tier (Developers)
- 100 API calls/month
- Basic verification only
- Community support
- **Revenue:** Lead generation for paid tiers

#### Professional ($99/month)
- 10,000 API calls/month
- Batch processing (up to 50 agents)
- Historical analysis
- Email support
- **Revenue:** $99 × 500 customers = $49,500 MRR

#### Enterprise ($499/month)
- 100,000 API calls/month
- Custom rules engine
- Real-time monitoring
- Dedicated support
- SLA guarantees
- **Revenue:** $499 × 100 customers = $49,900 MRR

#### Volume Pricing
- **Pay-as-you-go:** $0.01 per API call above tier limits
- **Enterprise contracts:** $5,000-50,000/year for high-volume customers

### Revenue Projections
- **Total API Revenue:** $99,400/month potential
- **Volume overages:** $10,000+/month additional
- **Enterprise contracts:** $25,000/month from large customers
- **Total Potential:** $134,400/month from API alone

## Documentation & Developer Experience

### API Documentation
- **OpenAPI/Swagger spec:** Complete API specification
- **Interactive docs:** Live testing environment
- **Code examples:** Multiple programming languages
- **Postman collection:** Ready-to-import API collection

### Developer Resources
```bash
# CLI tool for developers
npm install -g asf-cli

# Quick verification
asf verify --agent-id "bot123" --platform discord

# Batch processing
asf batch --file agents.json --webhook https://myapp.com/webhook
```

### SDKs for Popular Languages
- **JavaScript/Node.js:** `npm install asf-sdk`
- **Python:** `pip install asf-python-sdk`
- **Go:** `go get github.com/asf/go-sdk`
- **Java:** Maven/Gradle packages

## Deployment & Infrastructure

### Cloud Architecture
```
Load Balancer → API Gateway → ASF API Servers (auto-scaling)
                          ↓
              ASF Detection Engine (containerized)
                          ↓
              Database (PostgreSQL) + Redis (caching)
                          ↓
              Analytics & Logging (ELK stack)
```

### Performance Requirements
- **Response Time:** <2 seconds for single verification
- **Throughput:** 1000+ requests/second capability
- **Uptime:** 99.95% SLA for Enterprise customers
- **Scalability:** Auto-scaling to handle traffic spikes

This REST API component makes ASF accessible to any platform or application while generating substantial recurring revenue through tiered API pricing and enterprise contracts.

**Next:** Enterprise Dashboard for monitoring and management.