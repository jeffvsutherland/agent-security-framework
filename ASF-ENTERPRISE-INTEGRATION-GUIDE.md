# ASF Enterprise Integration Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Authentication Setup](#authentication-setup)  
3. [Platform Integration Patterns](#platform-integration-patterns)
4. [SDK Implementation Guide](#sdk-implementation-guide)
5. [Webhook Configuration](#webhook-configuration)
6. [Security Best Practices](#security-best-practices)
7. [Monitoring and Alerting](#monitoring-and-alerting)
8. [Troubleshooting](#troubleshooting)
9. [Enterprise Support](#enterprise-support)

---

## Getting Started

### Prerequisites
- Active ASF Enterprise subscription
- Development environment with HTTPS support
- API key with appropriate permissions
- Webhook endpoint for real-time notifications

### Quick Start Checklist
- [ ] Obtain enterprise API credentials
- [ ] Set up development environment
- [ ] Install ASF Enterprise SDK
- [ ] Configure basic agent verification
- [ ] Set up webhook endpoints
- [ ] Test integration with sample data
- [ ] Deploy to staging environment
- [ ] Complete security review
- [ ] Go live with monitoring

---

## Authentication Setup

### Enterprise API Key Management

#### 1. API Key Generation
```bash
# Request enterprise API key through ASF portal
curl -X POST https://enterprise-portal.asf.security/api/keys \
  -H "Authorization: Bearer <portal_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "key_name": "Production Platform Integration",
    "permissions": ["detect", "monitor", "analytics"],
    "rate_limit": "enterprise",
    "environment": "production"
  }'
```

#### 2. Secure Storage
```javascript
// Environment configuration
const config = {
  asf: {
    apiKey: process.env.ASF_ENTERPRISE_KEY, // Required
    environment: process.env.NODE_ENV || 'staging',
    baseUrl: process.env.ASF_BASE_URL || 'https://enterprise-api.asf.security/v1'
  }
};

// Key rotation handling
const keyManager = new ASFKeyManager({
  primaryKey: process.env.ASF_PRIMARY_KEY,
  backupKey: process.env.ASF_BACKUP_KEY,
  rotationSchedule: '30d'
});
```

#### 3. Multi-Environment Setup
```yaml
# docker-compose.yml for enterprise deployment
version: '3.8'
services:
  app:
    environment:
      - ASF_ENTERPRISE_KEY=${ASF_PROD_KEY}
      - ASF_ENVIRONMENT=production
      - ASF_WEBHOOK_SECRET=${ASF_WEBHOOK_SECRET}
      - ASF_RATE_LIMIT=enterprise
```

---

## Platform Integration Patterns

### 1. Discord Server Integration

#### Bot Registration Screening
```python
import discord
from asf_enterprise import EnterpriseDetector
import asyncio

class ASFSecurityBot(discord.Bot):
    def __init__(self):
        super().__init__()
        self.asf = EnterpriseDetector(
            api_key=os.environ['ASF_ENTERPRISE_KEY'],
            environment='production'
        )
    
    @discord.slash_command(name="verify_member")
    async def verify_member(self, ctx, user: discord.User):
        """Manual verification of suspicious member"""
        await ctx.defer()
        
        try:
            # Comprehensive analysis
            result = await self.asf.analyze_comprehensive(
                agent_id=str(user.id),
                platform='discord',
                profile_data={
                    'username': user.name,
                    'display_name': user.display_name,
                    'created_at': user.created_at.isoformat(),
                    'avatar_url': str(user.avatar) if user.avatar else None
                },
                custom_rules=['discord_bot_detection', 'spam_account_patterns']
            )
            
            # Create detailed embed response
            embed = discord.Embed(
                title=f"🛡️ ASF Verification: {user.display_name}",
                color=discord.Color.green() if result.overall_fake_probability < 0.3 
                      else discord.Color.orange() if result.overall_fake_probability < 0.7 
                      else discord.Color.red()
            )
            
            embed.add_field(
                name="Authenticity Score", 
                value=f"{(1 - result.overall_fake_probability) * 100:.1f}%",
                inline=True
            )
            embed.add_field(
                name="Confidence", 
                value=f"{result.confidence_level * 100:.1f}%",
                inline=True
            )
            embed.add_field(
                name="Recommendation", 
                value=result.recommended_action.replace('_', ' ').title(),
                inline=True
            )
            
            if result.detailed_analysis.behavioral_indicators.flags:
                flag_text = "\n".join([f"• {flag.replace('_', ' ').title()}" 
                                     for flag in result.detailed_analysis.behavioral_indicators.flags[:5]])
                embed.add_field(name="Risk Flags", value=flag_text, inline=False)
            
            await ctx.followup.send(embed=embed)
            
        except Exception as e:
            await ctx.followup.send(f"⚠️ Verification failed: {str(e)}")

    @discord.Cog.listener()
    async def on_member_join(self, member):
        """Automatic screening of new members"""
        # Skip verification for bots
        if member.bot:
            return
            
        try:
            # Quick verification for new members
            verification = await self.asf.verify_agent(
                agent_id=str(member.id),
                platform='discord',
                context={
                    'account_age_hours': (datetime.now() - member.created_at).total_seconds() / 3600,
                    'username': member.name,
                    'has_avatar': member.avatar is not None
                }
            )
            
            # Handle high-risk members
            if verification.overall_fake_probability > 0.8:
                # Notify moderation team
                mod_channel = discord.utils.get(member.guild.channels, name='mod-alerts')
                if mod_channel:
                    alert = discord.Embed(
                        title="🚨 High-Risk Member Detected",
                        description=f"{member.mention} flagged by ASF security",
                        color=discord.Color.red()
                    )
                    alert.add_field(name="Risk Score", value=f"{verification.overall_fake_probability * 100:.1f}%")
                    await mod_channel.send(embed=alert)
                
                # Apply quarantine role
                quarantine_role = discord.utils.get(member.guild.roles, name="Quarantine")
                if quarantine_role:
                    await member.add_roles(quarantine_role, reason="ASF Security: High fake probability")
            
            elif verification.overall_fake_probability < 0.2:
                # Grant verified member role
                verified_role = discord.utils.get(member.guild.roles, name="ASF Verified")
                if verified_role:
                    await member.add_roles(verified_role, reason="ASF Security: High authenticity score")
        
        except Exception as e:
            print(f"ASF verification failed for {member}: {e}")
```

#### Message Content Filtering
```python
@discord.Cog.listener()
async def on_message(self, message):
    """Real-time content authenticity checking"""
    if message.author.bot or not message.content:
        return
        
    # Check for spam/promotional content patterns
    if len(message.content) > 100:  # Only check longer messages
        content_check = await self.asf.verify_content_authenticity([{
            'content_id': str(message.id),
            'agent_id': str(message.author.id),
            'content_type': 'text',
            'content': message.content,
            'metadata': {
                'channel_id': str(message.channel.id),
                'timestamp': message.created_at.isoformat()
            }
        }])
        
        result = content_check.content_batch[0]
        if result.spam_probability > 0.85:
            await message.delete()
            await message.author.timeout(duration=datetime.timedelta(minutes=10), 
                                       reason="ASF: Spam content detected")
```

### 2. Moltbook Platform Integration

#### User Registration Pipeline
```javascript
// Express.js middleware for Moltbook registration
const express = require('express');
const { EnterpriseDetector } = require('@asf-security/enterprise-sdk');

const app = express();
const asf = new EnterpriseDetector({
  apiKey: process.env.ASF_ENTERPRISE_KEY,
  environment: 'production'
});

// Registration screening middleware
app.post('/api/auth/register', async (req, res, next) => {
  const { username, email, profile_data } = req.body;
  
  try {
    // Comprehensive screening for new registrations
    const screening = await asf.analyzeComprehensive({
      agent_data: {
        agent_id: username,
        platform: 'moltbook',
        profile: {
          username: username,
          email: email,
          ...profile_data
        },
        technical_indicators: {
          ip_addresses: [req.ip],
          user_agents: [req.get('User-Agent')],
          registration_fingerprint: req.fingerprint
        }
      },
      detection_config: {
        sensitivity: 'high',
        focus_areas: ['behavioral', 'technical', 'network'],
        custom_rules: ['moltbook_registration_patterns']
      }
    });
    
    // Handle screening results
    if (screening.overall_fake_probability > 0.8) {
      return res.status(403).json({
        error: 'Registration blocked',
        reason: 'Account flagged by security screening',
        appeal_url: 'https://platform.com/appeal'
      });
    } else if (screening.overall_fake_probability > 0.6) {
      // Require manual review
      req.pending_review = true;
      req.asf_score = screening.overall_fake_probability;
    }
    
    // Add ASF data to registration
    req.asf_verification = screening;
    next();
    
  } catch (error) {
    console.error('ASF registration screening failed:', error);
    // Continue registration without screening in case of ASF service issues
    next();
  }
});

// Complete registration with ASF data
app.post('/api/auth/register', async (req, res) => {
  const user = await createUser({
    ...req.body,
    asf_score: req.asf_verification?.overall_fake_probability,
    pending_review: req.pending_review || false,
    security_flags: req.asf_verification?.detailed_analysis.behavioral_indicators.flags || []
  });
  
  res.json({ 
    success: true, 
    user: user,
    verification_required: req.pending_review
  });
});
```

#### Content Moderation System
```javascript
// Real-time content analysis
app.post('/api/posts', authenticateUser, async (req, res) => {
  const { content, attachments } = req.body;
  const userId = req.user.id;
  
  try {
    // Content authenticity verification
    const contentCheck = await asf.verifyContentAuthenticity([{
      content_id: `temp_${Date.now()}`,
      agent_id: userId,
      content_type: 'text',
      content: content,
      metadata: {
        user_history: req.user.posting_history,
        account_age_days: req.user.account_age_days
      }
    }]);
    
    const result = contentCheck.content_batch[0];
    
    // Block obvious spam/fake content
    if (result.spam_probability > 0.9 || result.ai_generated_probability > 0.95) {
      return res.status(403).json({
        error: 'Content blocked',
        reason: 'Flagged as potentially inauthentic',
        details: {
          spam_score: result.spam_probability,
          ai_score: result.ai_generated_probability
        }
      });
    }
    
    // Create post with ASF metadata
    const post = await createPost({
      user_id: userId,
      content: content,
      asf_content_score: result.authenticity_score,
      moderation_flags: result.flags || [],
      needs_review: result.spam_probability > 0.7
    });
    
    res.json({ success: true, post: post });
    
  } catch (error) {
    console.error('Content verification failed:', error);
    // Fallback to standard moderation
    const post = await createPost({ user_id: userId, content: content });
    res.json({ success: true, post: post });
  }
});
```

### 3. GitHub Enterprise Integration

#### Repository Security Action
```yaml
# .github/workflows/asf-security.yml
name: ASF Security Scan
on:
  pull_request:
    types: [opened, synchronize]
  push:
    branches: [main, develop]

jobs:
  asf-security-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: ASF Contributor Verification
        uses: asf-security/github-action@v2
        with:
          asf-enterprise-key: ${{ secrets.ASF_ENTERPRISE_KEY }}
          check-contributors: true
          verify-commits: true
          analyze-code-patterns: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload ASF Security Report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: asf-security-report
          path: asf-security-report.json
      
      - name: Comment PR with ASF Results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('asf-security-report.json', 'utf8'));
            
            let comment = `## 🛡️ ASF Security Report\n\n`;
            comment += `**Contributors Verified:** ${report.contributors.verified}/${report.contributors.total}\n`;
            comment += `**Code Authenticity Score:** ${report.code_analysis.authenticity_score}/100\n\n`;
            
            if (report.security_flags.length > 0) {
              comment += `**⚠️ Security Flags:**\n`;
              report.security_flags.forEach(flag => {
                comment += `- ${flag.description} (${flag.severity})\n`;
              });
            }
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

---

## SDK Implementation Guide

### Node.js Enterprise SDK

#### Installation and Setup
```bash
npm install @asf-security/enterprise-sdk
```

```javascript
const { EnterpriseDetector, RealTimeMonitor } = require('@asf-security/enterprise-sdk');

// Initialize with enterprise configuration
const asf = new EnterpriseDetector({
  apiKey: process.env.ASF_ENTERPRISE_KEY,
  environment: 'production',
  options: {
    timeout: 10000,
    retries: 3,
    cache: {
      enabled: true,
      ttl: 900, // 15 minutes
      redis: {
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT
      }
    },
    rateLimiting: {
      enabled: true,
      maxRequests: 10000, // Enterprise tier
      window: 3600
    }
  }
});

// Error handling with circuit breaker
asf.on('error', (error) => {
  console.error('ASF SDK Error:', error);
  metrics.increment('asf.errors', 1, { error_type: error.type });
});

asf.on('rateLimit', (info) => {
  console.warn('ASF Rate Limit:', info);
  // Implement backoff strategy
  setTimeout(() => asf.resetRateLimit(), info.resetTime);
});
```

#### Advanced Detection Patterns
```javascript
// Comprehensive agent screening
async function screenNewAgent(agentData) {
  try {
    const result = await asf.analyzeComprehensive({
      agent_data: {
        agent_id: agentData.username,
        platform: agentData.platform,
        profile: agentData.profile,
        activity_history: await getAgentHistory(agentData.username),
        network_analysis: await getNetworkData(agentData.username),
        technical_indicators: {
          ip_addresses: agentData.ip_history,
          user_agents: agentData.user_agents,
          device_fingerprints: agentData.fingerprints
        }
      },
      detection_config: {
        sensitivity: 'high',
        focus_areas: ['behavioral', 'technical', 'content', 'network'],
        custom_rules: await getCustomRules(agentData.platform)
      }
    });
    
    // Log comprehensive analysis
    logger.info('Agent screening completed', {
      agent_id: agentData.username,
      fake_probability: result.overall_fake_probability,
      confidence: result.confidence_level,
      flags: result.detailed_analysis.behavioral_indicators.flags
    });
    
    return result;
    
  } catch (error) {
    logger.error('Agent screening failed', { error: error.message });
    // Return safe default
    return {
      overall_fake_probability: 0.5,
      confidence_level: 0.1,
      recommended_action: 'MANUAL_REVIEW'
    };
  }
}

// Batch processing for existing users
async function auditExistingUsers(userBatch) {
  const batchSize = 100; // Process in chunks
  const results = [];
  
  for (let i = 0; i < userBatch.length; i += batchSize) {
    const chunk = userBatch.slice(i, i + batchSize);
    
    try {
      const batchResult = await asf.analyzeBatch(chunk.map(user => ({
        agent_id: user.username,
        platform: user.platform,
        quick_analysis: true // Faster processing for audits
      })));
      
      results.push(...batchResult.results);
      
      // Rate limiting - wait between batches
      if (i + batchSize < userBatch.length) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
      
    } catch (error) {
      console.error(`Batch ${i}-${i + batchSize} failed:`, error);
      // Continue with next batch
    }
  }
  
  return results;
}
```

### Python Enterprise SDK

#### Installation and Configuration
```bash
pip install asf-enterprise-security
```

```python
from asf_enterprise import EnterpriseDetector, RealTimeMonitor
from asf_enterprise.exceptions import ASFException, RateLimitException
import asyncio
import logging

# Configure enterprise detector
detector = EnterpriseDetector(
    api_key=os.environ['ASF_ENTERPRISE_KEY'],
    environment='production',
    options={
        'timeout': 10.0,
        'max_retries': 3,
        'cache_enabled': True,
        'cache_ttl': 900,  # 15 minutes
        'redis_url': os.environ.get('REDIS_URL'),
        'custom_rules_enabled': True
    }
)

# Enterprise-grade error handling
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10),
    retry=retry_if_exception_type((ASFException, ConnectionError))
)
async def verify_agent_with_retry(agent_id: str, platform: str, context: dict = None):
    """Verify agent with enterprise-grade retry logic"""
    try:
        result = await detector.analyze_comprehensive(
            agent_id=agent_id,
            platform=platform,
            profile_data=context.get('profile', {}),
            activity_history=context.get('activity', {}),
            custom_rules=['enterprise_threat_detection']
        )
        
        # Log for audit trail
        logging.info(f"Agent verification completed: {agent_id}", extra={
            'agent_id': agent_id,
            'platform': platform,
            'fake_probability': result.overall_fake_probability,
            'confidence': result.confidence_level
        })
        
        return result
        
    except RateLimitException as e:
        logging.warning(f"Rate limit hit, backing off: {e.retry_after}s")
        await asyncio.sleep(e.retry_after)
        raise
        
    except ASFException as e:
        logging.error(f"ASF verification failed: {e}")
        raise
```

#### Real-time Monitoring Implementation
```python
class AgentMonitoringService:
    def __init__(self):
        self.detector = detector
        self.monitored_agents = set()
        self.alert_handlers = []
    
    async def start_monitoring(self, agent_ids: List[str], platform: str):
        """Start real-time behavioral monitoring"""
        monitor = await self.detector.create_behavioral_monitor(
            agent_ids=agent_ids,
            platform=platform,
            monitoring_config={
                'duration': '24h',
                'alert_thresholds': {
                    'fake_probability': 0.7,
                    'behavior_change_score': 0.8,
                    'suspicious_activity_spike': 0.75
                },
                'analysis_focus': [
                    'posting_frequency_changes',
                    'content_style_shifts',
                    'interaction_pattern_anomalies'
                ]
            }
        )
        
        # Set up alert callbacks
        monitor.on_alert(self.handle_security_alert)
        monitor.on_pattern_detected(self.handle_pattern_detection)
        
        self.monitored_agents.update(agent_ids)
        return monitor
    
    async def handle_security_alert(self, alert_data):
        """Handle real-time security alerts"""
        severity = alert_data.get('severity', 'medium')
        agent_id = alert_data.get('agent_id')
        
        logging.critical(f"Security alert for {agent_id}", extra=alert_data)
        
        # Execute automated responses based on severity
        if severity == 'critical':
            await self.execute_emergency_response(agent_id, alert_data)
        elif severity == 'high':
            await self.flag_for_immediate_review(agent_id, alert_data)
        
        # Notify security team
        await self.notify_security_team(alert_data)
    
    async def execute_emergency_response(self, agent_id: str, alert_data: dict):
        """Automated emergency response procedures"""
        actions = []
        
        # Immediate suspension
        await self.suspend_agent_account(agent_id)
        actions.append('account_suspended')
        
        # Quarantine content
        await self.quarantine_agent_content(agent_id)
        actions.append('content_quarantined')
        
        # Block network connections
        if 'network_cluster' in alert_data.get('threat_indicators', []):
            cluster_agents = alert_data.get('related_agents', [])
            await self.investigate_agent_cluster(cluster_agents)
            actions.append('cluster_investigation_initiated')
        
        logging.info(f"Emergency response executed for {agent_id}: {actions}")
```

---

## Webhook Configuration

### Webhook Endpoint Setup

#### 1. Secure Webhook Receiver
```python
from flask import Flask, request, jsonify
import hmac
import hashlib
import json

app = Flask(__name__)

@app.route('/webhooks/asf-security', methods=['POST'])
def handle_asf_webhook():
    """Secure ASF webhook handler"""
    
    # Verify webhook signature
    signature = request.headers.get('X-ASF-Signature-256')
    if not verify_webhook_signature(request.data, signature):
        return jsonify({'error': 'Invalid signature'}), 401
    
    try:
        event_data = request.json
        event_type = event_data.get('event')
        
        # Route to appropriate handler
        handlers = {
            'high_confidence_fake_detected': handle_fake_agent_alert,
            'coordinated_campaign_identified': handle_campaign_alert,
            'new_threat_pattern_discovered': handle_new_threat,
            'mass_registration_anomaly': handle_registration_anomaly
        }
        
        handler = handlers.get(event_type)
        if handler:
            await handler(event_data)
        else:
            logging.warning(f"Unknown webhook event type: {event_type}")
        
        return jsonify({'status': 'processed'}), 200
        
    except Exception as e:
        logging.error(f"Webhook processing failed: {e}")
        return jsonify({'error': 'Processing failed'}), 500

def verify_webhook_signature(payload: bytes, signature: str) -> bool:
    """Verify ASF webhook signature"""
    if not signature:
        return False
    
    expected_signature = hmac.new(
        os.environ['ASF_WEBHOOK_SECRET'].encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(f"sha256={expected_signature}", signature)

async def handle_fake_agent_alert(event_data: dict):
    """Handle high-confidence fake agent detection"""
    agent_ids = event_data['data']['agent_ids']
    threat_assessment = event_data['data']['threat_assessment']
    
    # Immediate automated response
    for agent_id in agent_ids:
        await emergency_suspend_agent(agent_id)
        await quarantine_agent_content(agent_id)
    
    # Alert security team
    await send_security_alert({
        'type': 'fake_agent_detection',
        'severity': 'critical',
        'agent_count': len(agent_ids),
        'threat_level': threat_assessment.get('threat_level'),
        'recommended_actions': event_data['data']['recommended_actions']
    })
```

#### 2. Webhook Event Routing
```javascript
// Express.js webhook router
const express = require('express');
const crypto = require('crypto');
const router = express.Router();

// Webhook signature verification middleware
function verifyWebhookSignature(req, res, next) {
  const signature = req.get('X-ASF-Signature-256');
  const payload = JSON.stringify(req.body);
  
  const expectedSignature = crypto
    .createHmac('sha256', process.env.ASF_WEBHOOK_SECRET)
    .update(payload)
    .digest('hex');
  
  if (!crypto.timingSafeEqual(
    Buffer.from(`sha256=${expectedSignature}`),
    Buffer.from(signature || '')
  )) {
    return res.status(401).json({ error: 'Invalid signature' });
  }
  
  next();
}

// Event handlers
const eventHandlers = {
  'high_confidence_fake_detected': async (data) => {
    // Immediate blocking action
    const agentIds = data.agent_ids;
    await Promise.all(agentIds.map(id => blockAgentImmediately(id)));
    
    // Notify moderation team
    await notifyModerationTeam({
      type: 'critical_fake_detection',
      agents: agentIds,
      evidence: data.threat_assessment
    });
  },
  
  'coordinated_campaign_identified': async (data) => {
    // Campaign-level response
    const campaign = data.campaign_data;
    
    // Block all associated agents
    await blockAgentCluster(campaign.agent_ids);
    
    // Update detection rules
    await updateDetectionRules(campaign.behavior_patterns);
    
    // Alert security operations
    await escalateToSecurityOps({
      campaign_id: campaign.id,
      scale: campaign.estimated_reach,
      threat_level: campaign.threat_level
    });
  },
  
  'new_threat_pattern_discovered': async (data) => {
    // Update security rules
    await deployNewSecurityRules(data.pattern_data);
    
    // Analyze existing users for this pattern
    await scanExistingUsersForPattern(data.pattern_signature);
  }
};

router.post('/asf-webhooks', verifyWebhookSignature, async (req, res) => {
  const { event, data, timestamp } = req.body;
  
  // Check event freshness (prevent replay attacks)
  const eventTime = new Date(timestamp);
  const now = new Date();
  if (now - eventTime > 5 * 60 * 1000) { // 5 minutes
    return res.status(400).json({ error: 'Event too old' });
  }
  
  try {
    const handler = eventHandlers[event];
    if (handler) {
      await handler(data);
      res.json({ status: 'processed', event });
    } else {
      res.status(400).json({ error: 'Unknown event type' });
    }
  } catch (error) {
    console.error('Webhook processing error:', error);
    res.status(500).json({ error: 'Processing failed' });
  }
});
```

---

## Security Best Practices

### 1. API Key Security
```bash
# Environment-based key management
export ASF_ENTERPRISE_KEY="asf_ent_1234567890abcdef..."
export ASF_WEBHOOK_SECRET="webhook_secret_key..."
export ASF_BACKUP_KEY="asf_backup_key..."

# Key rotation script
#!/bin/bash
# rotate-asf-keys.sh
set -e

echo "Rotating ASF Enterprise API keys..."

# Generate new key via ASF portal
NEW_KEY=$(curl -s -X POST https://enterprise-portal.asf.security/api/keys/rotate \
  -H "Authorization: Bearer $ASF_PORTAL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"current_key": "'$ASF_ENTERPRISE_KEY'"}' | jq -r '.new_key')

if [ "$NEW_KEY" != "null" ]; then
  # Update environment
  export ASF_BACKUP_KEY=$ASF_ENTERPRISE_KEY
  export ASF_ENTERPRISE_KEY=$NEW_KEY
  
  # Update application configuration
  kubectl create secret generic asf-enterprise-keys \
    --from-literal=primary-key=$ASF_ENTERPRISE_KEY \
    --from-literal=backup-key=$ASF_BACKUP_KEY \
    --dry-run=client -o yaml | kubectl apply -f -
  
  echo "Keys rotated successfully"
else
  echo "Key rotation failed"
  exit 1
fi
```

### 2. Request Authentication
```python
import jwt
import time
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa, padding

class SecureASFClient:
    def __init__(self, api_key: str, private_key_path: str):
        self.api_key = api_key
        self.private_key = self.load_private_key(private_key_path)
    
    def generate_request_signature(self, method: str, path: str, body: str) -> str:
        """Generate request signature for enhanced security"""
        timestamp = int(time.time())
        payload = f"{method}:{path}:{body}:{timestamp}"
        
        signature = self.private_key.sign(
            payload.encode(),
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        
        return base64.b64encode(signature).decode()
    
    async def secure_request(self, method: str, endpoint: str, data: dict = None):
        """Make authenticated request with signature verification"""
        body = json.dumps(data) if data else ""
        signature = self.generate_request_signature(method, endpoint, body)
        
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'X-ASF-Signature': signature,
            'X-ASF-Timestamp': str(int(time.time())),
            'Content-Type': 'application/json'
        }
        
        # Make request with timeout and retries
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.request(
                method=method,
                url=f"https://enterprise-api.asf.security/v1{endpoint}",
                headers=headers,
                content=body
            )
            
            if response.status_code == 429:
                # Handle rate limiting
                retry_after = int(response.headers.get('Retry-After', 60))
                await asyncio.sleep(retry_after)
                return await self.secure_request(method, endpoint, data)
            
            response.raise_for_status()
            return response.json()
```

### 3. Data Privacy and Compliance
```python
from cryptography.fernet import Fernet
import hashlib

class PrivacyCompliantASF:
    def __init__(self, encryption_key: bytes):
        self.cipher = Fernet(encryption_key)
    
    def anonymize_user_data(self, user_data: dict) -> dict:
        """Anonymize sensitive user data for ASF analysis"""
        sensitive_fields = ['email', 'ip_address', 'device_id']
        
        anonymized = user_data.copy()
        for field in sensitive_fields:
            if field in anonymized:
                # Hash sensitive data
                anonymized[field] = hashlib.sha256(
                    str(anonymized[field]).encode()
                ).hexdigest()[:16]  # Truncated hash
        
        return anonymized
    
    def encrypt_api_payload(self, payload: dict) -> str:
        """Encrypt sensitive API payload data"""
        json_data = json.dumps(payload)
        encrypted = self.cipher.encrypt(json_data.encode())
        return base64.b64encode(encrypted).decode()
    
    async def gdpr_compliant_verification(self, user_data: dict):
        """GDPR-compliant agent verification"""
        # Anonymize before sending to ASF
        anonymized_data = self.anonymize_user_data(user_data)
        
        # Add privacy headers
        headers = {
            'X-ASF-Privacy-Mode': 'gdpr',
            'X-ASF-Data-Retention': '30d',  # Auto-delete after 30 days
            'X-ASF-Anonymization': 'sha256-truncated'
        }
        
        result = await asf_client.verify_agent(
            anonymized_data,
            headers=headers
        )
        
        # Log for compliance audit
        compliance_log.info("GDPR verification completed", {
            'user_hash': hashlib.sha256(user_data['user_id'].encode()).hexdigest()[:16],
            'data_processed': list(anonymized_data.keys()),
            'retention_period': '30d'
        })
        
        return result
```

---

## Monitoring and Alerting

### 1. Metrics Collection
```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Prometheus metrics
asf_requests_total = Counter('asf_requests_total', 'Total ASF API requests', ['method', 'status'])
asf_request_duration = Histogram('asf_request_duration_seconds', 'ASF request duration')
asf_fake_detections = Counter('asf_fake_detections_total', 'Total fake agents detected', ['severity'])
asf_api_errors = Counter('asf_api_errors_total', 'ASF API errors', ['error_type'])

class MonitoredASFClient:
    def __init__(self, detector):
        self.detector = detector
    
    @asf_request_duration.time()
    async def verify_agent_with_monitoring(self, agent_id: str, platform: str):
        """Verify agent with comprehensive monitoring"""
        start_time = time.time()
        
        try:
            result = await self.detector.verify_agent(agent_id, platform)
            
            # Record success metrics
            asf_requests_total.labels(method='verify_agent', status='success').inc()
            
            # Record threat detection
            if result.overall_fake_probability > 0.8:
                asf_fake_detections.labels(severity='high').inc()
            elif result.overall_fake_probability > 0.6:
                asf_fake_detections.labels(severity='medium').inc()
            
            return result
            
        except ASFException as e:
            asf_requests_total.labels(method='verify_agent', status='error').inc()
            asf_api_errors.labels(error_type=type(e).__name__).inc()
            raise
        
        finally:
            duration = time.time() - start_time
            logging.info(f"ASF verification completed in {duration:.3f}s", extra={
                'agent_id': agent_id,
                'platform': platform,
                'duration': duration
            })
```

### 2. Health Monitoring
```python
from fastapi import FastAPI
from fastapi.responses import JSONResponse
import asyncio

app = FastAPI()

@app.get("/health/asf")
async def asf_health_check():
    """Comprehensive ASF integration health check"""
    health_status = {
        'status': 'healthy',
        'checks': {},
        'timestamp': datetime.utcnow().isoformat()
    }
    
    # API connectivity check
    try:
        test_result = await asf.verify_agent('HealthCheckAgent', 'test')
        health_status['checks']['api_connectivity'] = {
            'status': 'pass',
            'response_time': test_result.response_time
        }
    except Exception as e:
        health_status['checks']['api_connectivity'] = {
            'status': 'fail',
            'error': str(e)
        }
        health_status['status'] = 'degraded'
    
    # Webhook endpoint check
    try:
        webhook_test = await test_webhook_endpoint()
        health_status['checks']['webhook'] = {
            'status': 'pass' if webhook_test else 'fail'
        }
    except Exception as e:
        health_status['checks']['webhook'] = {
            'status': 'fail',
            'error': str(e)
        }
    
    # Rate limit status
    rate_limit_info = await asf.get_rate_limit_status()
    health_status['checks']['rate_limits'] = {
        'status': 'pass' if rate_limit_info.remaining > 100 else 'warn',
        'remaining': rate_limit_info.remaining,
        'reset_time': rate_limit_info.reset_time
    }
    
    # Cache status (if enabled)
    if hasattr(asf, 'cache'):
        cache_status = await asf.cache.health_check()
        health_status['checks']['cache'] = {
            'status': 'pass' if cache_status.healthy else 'fail',
            'hit_rate': cache_status.hit_rate
        }
    
    return JSONResponse(
        content=health_status,
        status_code=200 if health_status['status'] == 'healthy' else 503
    )
```

### 3. Alert Configuration
```yaml
# Prometheus AlertManager configuration
groups:
  - name: asf_security
    rules:
      - alert: ASFHighFakeDetectionRate
        expr: rate(asf_fake_detections_total[5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High rate of fake agent detections"
          description: "Detecting {{ $value }} fake agents per second"
      
      - alert: ASFAPIErrors
        expr: rate(asf_api_errors_total[5m]) > 0.1
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "ASF API error rate elevated"
          description: "ASF API error rate is {{ $value }} errors/sec"
      
      - alert: ASFResponseTimeHigh
        expr: histogram_quantile(0.95, asf_request_duration_seconds_bucket) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "ASF response time degraded"
          description: "95th percentile response time is {{ $value }}s"
      
      - alert: ASFRateLimitApproaching
        expr: asf_rate_limit_remaining < 1000
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "ASF rate limit approaching"
          description: "Only {{ $value }} requests remaining"
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. API Authentication Issues
```python
async def diagnose_auth_issues():
    """Diagnose and resolve authentication problems"""
    
    # Check API key validity
    try:
        response = await asf.test_authentication()
        print("✅ API key valid")
    except AuthenticationError as e:
        print(f"❌ Authentication failed: {e}")
        print("Solutions:")
        print("1. Verify API key is correct")
        print("2. Check key hasn't expired")
        print("3. Ensure key has required permissions")
        return
    
    # Check rate limits
    try:
        rate_info = await asf.get_rate_limit_status()
        if rate_info.remaining < 100:
            print(f"⚠️  Rate limit low: {rate_info.remaining} requests remaining")
            print(f"Resets at: {rate_info.reset_time}")
        else:
            print("✅ Rate limits OK")
    except Exception as e:
        print(f"❌ Rate limit check failed: {e}")
```

#### 2. Webhook Delivery Issues
```python
def debug_webhook_issues():
    """Debug webhook delivery problems"""
    
    # Test webhook endpoint accessibility
    webhook_url = os.environ.get('ASF_WEBHOOK_URL')
    
    try:
        response = requests.post(webhook_url + '/test', 
                               json={'test': True},
                               timeout=10)
        if response.status_code == 200:
            print("✅ Webhook endpoint accessible")
        else:
            print(f"❌ Webhook returned {response.status_code}")
    except requests.exceptions.Timeout:
        print("❌ Webhook timeout - check firewall/proxy settings")
    except requests.exceptions.ConnectionError:
        print("❌ Cannot reach webhook endpoint")
    
    # Verify webhook signature handling
    test_payload = json.dumps({'test': 'data'})
    test_signature = generate_webhook_signature(test_payload)
    
    if verify_webhook_signature(test_payload.encode(), test_signature):
        print("✅ Webhook signature verification working")
    else:
        print("❌ Webhook signature verification failed")
```

#### 3. Performance Optimization
```python
# Connection pooling for better performance
import httpx

class OptimizedASFClient:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.client = httpx.AsyncClient(
            limits=httpx.Limits(
                max_keepalive_connections=20,
                max_connections=100,
                keepalive_expiry=30
            ),
            timeout=httpx.Timeout(30.0)
        )
    
    async def batch_verify_optimized(self, agents: List[dict]) -> List[dict]:
        """Optimized batch verification with connection reuse"""
        
        # Process in optimal batch sizes
        batch_size = 50  # Tune based on your needs
        results = []
        
        for i in range(0, len(agents), batch_size):
            batch = agents[i:i + batch_size]
            
            # Parallel requests within batch
            tasks = []
            for agent in batch:
                task = self.verify_single_agent(agent)
                tasks.append(task)
            
            batch_results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Handle any exceptions
            for j, result in enumerate(batch_results):
                if isinstance(result, Exception):
                    logging.error(f"Verification failed for agent {batch[j]['agent_id']}: {result}")
                    results.append({
                        'agent_id': batch[j]['agent_id'],
                        'error': str(result),
                        'fake_probability': 0.5  # Safe default
                    })
                else:
                    results.append(result)
            
            # Brief pause between batches to avoid rate limiting
            if i + batch_size < len(agents):
                await asyncio.sleep(0.1)
        
        return results
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()
```

### Support Escalation Process

#### 1. Issue Classification
```python
def classify_support_issue(error_details: dict) -> str:
    """Automatically classify support issues for proper routing"""
    
    error_type = error_details.get('error_type')
    severity = error_details.get('severity', 'medium')
    
    if error_type in ['authentication_failed', 'invalid_api_key']:
        return 'tier1_auth'
    elif error_type in ['rate_limit_exceeded', 'quota_exceeded']:
        return 'tier1_limits'
    elif error_type in ['webhook_delivery_failed', 'signature_mismatch']:
        return 'tier2_integration'
    elif severity == 'critical' or 'security' in error_type:
        return 'tier3_security'
    else:
        return 'tier2_technical'

async def create_support_ticket(issue_details: dict):
    """Create structured support ticket with diagnostic info"""
    
    ticket_data = {
        'title': issue_details['summary'],
        'description': issue_details['description'],
        'classification': classify_support_issue(issue_details),
        'priority': issue_details.get('severity', 'medium'),
        'environment': os.environ.get('ASF_ENVIRONMENT', 'production'),
        'api_key_hash': hashlib.sha256(asf.api_key.encode()).hexdigest()[:8],
        'diagnostics': await collect_diagnostic_info(),
        'logs': issue_details.get('logs', []),
        'contact': {
            'email': os.environ.get('SUPPORT_EMAIL'),
            'company': os.environ.get('COMPANY_NAME'),
            'platform': issue_details.get('platform')
        }
    }
    
    # Submit to ASF support system
    response = await submit_support_request(ticket_data)
    return response['ticket_id']
```

---

## Enterprise Support

### Support Channels
- **Emergency Hotline**: +1-555-ASF-HELP (24/7 for critical issues)
- **Email Support**: enterprise-support@asf.security
- **Slack Integration**: Connect your Slack workspace for real-time support
- **Dedicated Account Manager**: For enterprise customers
- **Developer Portal**: https://enterprise.asf.security/support

### Service Level Agreement (SLA)
- **Critical Issues**: 1-hour response, 4-hour resolution target
- **High Priority**: 4-hour response, 24-hour resolution target  
- **Standard Issues**: 24-hour response, 72-hour resolution target
- **Feature Requests**: 48-hour acknowledgment, roadmap review

### Professional Services
- **Implementation Consulting**: Expert guidance for complex integrations
- **Custom Rule Development**: Tailored detection rules for your platform
- **Security Audits**: Comprehensive review of your ASF integration
- **Training Programs**: Team training on ASF security best practices

---

**This comprehensive integration guide ensures successful enterprise deployment of ASF security capabilities.** 🛡️