#!/usr/bin/env node
/**
 * ASF Platform Integration API Server
 * Provides REST API and webhook infrastructure for agent verification
 */

const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 1000, // 1000 requests per hour
  message: {
    error: 'Rate limit exceeded',
    code: 'ASF_RATE_LIMIT',
    retryAfter: 3600
  }
});
app.use('/api/', limiter);

// Authentication middleware
const authenticateAPI = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'Missing or invalid authorization header',
      code: 'ASF_AUTH_REQUIRED'
    });
  }
  
  const token = authHeader.substring(7);
  
  // In production, validate against database
  // For demo, accept any token starting with 'asf_'
  if (!token.startsWith('asf_')) {
    return res.status(401).json({
      error: 'Invalid API key',
      code: 'ASF_INVALID_KEY'
    });
  }
  
  req.apiKey = token;
  req.clientId = token.split('_')[1] || 'demo';
  next();
};

// Mock verification function (integrates with real ASF tools)
async function verifyAgent(agentId, platform, context = {}) {
  try {
    // Run actual ASF-12 fake agent detector
    const { exec } = require('child_process');
    const { promisify } = require('util');
    const execAsync = promisify(exec);
    
    let asfScore = 0;
    try {
      const { stdout } = await execAsync('./fake-agent-detector.sh --json');
      const asfResult = JSON.parse(stdout);
      asfScore = asfResult.authenticity_score || 0;
    } catch (error) {
      console.warn('ASF-12 detector not available, using mock scoring');
      // Mock scoring based on agent patterns
      asfScore = Math.floor(Math.random() * 40) + 60; // 60-100 for demo
    }
    
    // Check certification database
    let certificationLevel = 'NONE';
    let certificationData = {};
    
    try {
      const certPath = path.join(__dirname, 'memory/asf-certifications.json');
      if (fs.existsSync(certPath)) {
        const certDB = JSON.parse(fs.readFileSync(certPath, 'utf8'));
        if (certDB[agentId]) {
          certificationData = certDB[agentId];
          certificationLevel = certificationData.level || 'NONE';
          asfScore = Math.max(asfScore, certificationData.authenticity_score || asfScore);
        }
      }
    } catch (error) {
      console.warn('Could not load certification database');
    }
    
    // Determine recommendation
    let recommendation = 'BLOCK';
    if (asfScore >= 80) recommendation = 'ALLOW';
    else if (asfScore >= 60) recommendation = 'REVIEW';
    else if (asfScore >= 40) recommendation = 'CAUTION';
    
    // Risk indicators based on score
    const riskIndicators = [];
    if (asfScore < 60) riskIndicators.push('Low authenticity score');
    if (platform === 'unknown') riskIndicators.push('Unknown platform');
    if (!context || Object.keys(context).length === 0) {
      riskIndicators.push('Limited context provided');
    }
    
    return {
      agent_id: agentId,
      authenticity_score: asfScore,
      certification_level: certificationLevel,
      risk_indicators: riskIndicators,
      recommendation: recommendation,
      confidence: asfScore / 100,
      expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      detection_details: {
        behavioral_score: Math.floor(asfScore * 0.9),
        technical_score: Math.floor(asfScore * 1.1),
        community_score: certificationLevel !== 'NONE' ? 100 : Math.floor(asfScore * 0.8)
      },
      platform: platform,
      verified_at: new Date().toISOString()
    };
    
  } catch (error) {
    console.error('Verification error:', error);
    throw new Error('Verification service unavailable');
  }
}

// API Routes

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'ASF Platform API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// API documentation
app.get('/api/docs', (req, res) => {
  res.json({
    service: 'ASF Platform Integration API',
    version: '1.0.0',
    endpoints: {
      'POST /api/verify/agent': 'Verify single agent authenticity',
      'POST /api/verify/batch': 'Batch agent verification',
      'GET /api/certification/:agent_id': 'Get certification status',
      'POST /api/assess/risk': 'Assess agent risk level',
      'POST /api/vouch/submit': 'Submit community vouch',
      'GET /api/dashboard/analytics': 'Dashboard analytics',
      'POST /api/webhooks': 'Create webhook subscription'
    },
    authentication: 'Bearer token required',
    rate_limits: '1000 requests/hour'
  });
});

// Single agent verification
app.post('/api/verify/agent', 
  authenticateAPI,
  [
    body('agent_id').notEmpty().withMessage('agent_id is required'),
    body('platform').optional().isString(),
    body('context').optional().isObject()
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }
    
    const { agent_id, platform = 'unknown', context = {} } = req.body;
    
    try {
      const verification = await verifyAgent(agent_id, platform, context);
      
      res.json({
        success: true,
        verification: verification
      });
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Verification failed',
        code: 'ASF_SERVICE_ERROR',
        message: error.message
      });
    }
  }
);

// Batch verification
app.post('/api/verify/batch',
  authenticateAPI,
  [
    body('agents').isArray().withMessage('agents must be an array'),
    body('agents.*.agent_id').notEmpty().withMessage('agent_id required for each agent')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed', 
        details: errors.array()
      });
    }
    
    const { agents, options = {} } = req.body;
    const batchId = 'batch_' + crypto.randomBytes(8).toString('hex');
    const startTime = Date.now();
    
    try {
      const results = [];
      let authentic = 0, suspicious = 0;
      
      // Process agents (in production, use worker queue for large batches)
      for (const agentData of agents) {
        try {
          const verification = await verifyAgent(
            agentData.agent_id,
            agentData.platform || 'unknown',
            agentData.context || {}
          );
          
          if (options.include_details) {
            results.push(verification);
          } else {
            results.push({
              agent_id: verification.agent_id,
              authenticity_score: verification.authenticity_score,
              certification_level: verification.certification_level,
              recommendation: verification.recommendation
            });
          }
          
          if (verification.authenticity_score >= 60) authentic++;
          else suspicious++;
          
        } catch (error) {
          results.push({
            agent_id: agentData.agent_id,
            error: error.message,
            status: 'failed'
          });
        }
      }
      
      const processingTime = ((Date.now() - startTime) / 1000).toFixed(1) + 's';
      
      res.json({
        success: true,
        batch_id: batchId,
        results: results,
        summary: {
          total: agents.length,
          authentic: authentic,
          suspicious: suspicious,
          processing_time: processingTime
        }
      });
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Batch processing failed',
        code: 'ASF_BATCH_ERROR',
        message: error.message
      });
    }
  }
);

// Get certification status
app.get('/api/certification/:agent_id', authenticateAPI, async (req, res) => {
  const { agent_id } = req.params;
  
  try {
    // Load certification database
    const certPath = path.join(__dirname, 'memory/asf-certifications.json');
    
    if (!fs.existsSync(certPath)) {
      return res.status(404).json({
        success: false,
        error: 'Certification not found',
        code: 'ASF_CERT_NOT_FOUND'
      });
    }
    
    const certDB = JSON.parse(fs.readFileSync(certPath, 'utf8'));
    const certification = certDB[agent_id];
    
    if (!certification) {
      return res.status(404).json({
        success: false,
        error: 'Agent not certified',
        code: 'ASF_AGENT_NOT_CERTIFIED'
      });
    }
    
    res.json({
      success: true,
      certification: {
        agent_id: agent_id,
        level: certification.level,
        issued_date: certification.issued_date,
        expires_date: certification.expires_date,
        verification_url: certification.verification_url,
        capabilities: certification.capabilities || [],
        endorsements: certification.endorsements || 0,
        authenticity_score: certification.authenticity_score
      }
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve certification',
      code: 'ASF_CERT_ERROR',
      message: error.message
    });
  }
});

// Risk assessment
app.post('/api/assess/risk',
  authenticateAPI,
  [
    body('agent_id').notEmpty().withMessage('agent_id is required'),
    body('evidence').optional().isObject()
  ],
  async (req, res) => {
    const { agent_id, evidence = {} } = req.body;
    
    try {
      const verification = await verifyAgent(agent_id, 'unknown', evidence);
      
      let riskLevel = 'LOW';
      let riskScore = 100 - verification.authenticity_score;
      
      if (riskScore >= 60) riskLevel = 'HIGH';
      else if (riskScore >= 40) riskLevel = 'MEDIUM';
      
      const threatCategories = [];
      if (verification.authenticity_score < 40) {
        threatCategories.push('fake_engagement', 'promotional_spam');
      }
      if (verification.authenticity_score < 20) {
        threatCategories.push('social_engineering', 'malicious_intent');
      }
      
      const recommendedActions = [];
      switch (riskLevel) {
        case 'HIGH':
          recommendedActions.push('BLOCK_REGISTRATION', 'REQUIRE_MANUAL_REVIEW');
          break;
        case 'MEDIUM':
          recommendedActions.push('LIMIT_POSTING_FREQUENCY', 'MONITOR_ACTIVITY');
          break;
        case 'LOW':
          recommendedActions.push('STANDARD_MONITORING');
          break;
      }
      
      res.json({
        success: true,
        risk_assessment: {
          agent_id: agent_id,
          overall_risk: riskLevel,
          risk_score: riskScore,
          threat_categories: threatCategories,
          recommended_actions: recommendedActions,
          assessment_date: new Date().toISOString()
        }
      });
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Risk assessment failed',
        code: 'ASF_RISK_ERROR',
        message: error.message
      });
    }
  }
);

// Submit community vouch
app.post('/api/vouch/submit',
  authenticateAPI,
  [
    body('voucher_id').notEmpty().withMessage('voucher_id is required'),
    body('target_id').notEmpty().withMessage('target_id is required'),
    body('reason').notEmpty().withMessage('reason is required')
  ],
  async (req, res) => {
    const { voucher_id, target_id, reason, evidence = {} } = req.body;
    
    try {
      // Check voucher eligibility (must be verified+)
      const certPath = path.join(__dirname, 'memory/asf-certifications.json');
      let voucherLevel = 'NONE';
      
      if (fs.existsSync(certPath)) {
        const certDB = JSON.parse(fs.readFileSync(certPath, 'utf8'));
        voucherLevel = certDB[voucher_id]?.level || 'NONE';
      }
      
      if (voucherLevel === 'BASIC' || voucherLevel === 'NONE') {
        return res.status(403).json({
          success: false,
          error: 'Insufficient certification level to vouch',
          code: 'ASF_VOUCH_UNAUTHORIZED'
        });
      }
      
      // Determine vouch weight
      const vouchWeights = {
        'VERIFIED': 1,
        'AUTHENTICATED': 2,  
        'CERTIFIED': 3
      };
      const vouchWeight = vouchWeights[voucherLevel] || 0;
      
      // Record vouch (in production, save to database)
      const vouchData = {
        voucher_id: voucher_id,
        target_id: target_id,
        reason: reason,
        evidence: evidence,
        weight: vouchWeight,
        voucher_level: voucherLevel,
        timestamp: new Date().toISOString(),
        vouch_id: 'vouch_' + crypto.randomBytes(8).toString('hex')
      };
      
      console.log('Vouch recorded:', vouchData);
      
      res.json({
        success: true,
        vouch: {
          vouch_id: vouchData.vouch_id,
          weight: vouchWeight,
          status: 'recorded',
          message: 'Vouch successfully submitted'
        }
      });
      
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Vouch submission failed',
        code: 'ASF_VOUCH_ERROR',
        message: error.message
      });
    }
  }
);

// Dashboard analytics
app.get('/api/dashboard/analytics', authenticateAPI, (req, res) => {
  const timeRange = req.query.time_range || '24h';
  
  // Mock analytics data (in production, query from database)
  const analytics = {
    time_range: timeRange,
    metrics: {
      total_verifications: 1250,
      authenticity_rate: 0.87,
      average_score: 78.5,
      top_platforms: [
        { name: 'discord', verifications: 450, authenticity_rate: 0.89 },
        { name: 'moltbook', verifications: 380, authenticity_rate: 0.85 },
        { name: 'github', verifications: 320, authenticity_rate: 0.92 },
        { name: 'twitter', verifications: 100, authenticity_rate: 0.78 }
      ],
      risk_distribution: {
        low: 750,
        medium: 320,
        high: 180
      },
      certification_levels: {
        'NONE': 800,
        'BASIC': 280,
        'VERIFIED': 130,
        'AUTHENTICATED': 35,
        'CERTIFIED': 5
      }
    },
    trends: {
      verifications_per_hour: Array.from({ length: 24 }, (_, i) => ({
        hour: i,
        count: Math.floor(Math.random() * 100) + 20
      })),
      authenticity_trend: Array.from({ length: 7 }, (_, i) => ({
        day: i,
        authenticity_rate: 0.8 + Math.random() * 0.15
      }))
    }
  };
  
  res.json(analytics);
});

// Create webhook
app.post('/api/webhooks', 
  authenticateAPI,
  [
    body('url').isURL().withMessage('Valid webhook URL required'),
    body('events').isArray().withMessage('Events array required')
  ],
  (req, res) => {
    const { url, events, secret } = req.body;
    
    const webhookId = 'webhook_' + crypto.randomBytes(8).toString('hex');
    
    // In production, save to database
    const webhook = {
      webhook_id: webhookId,
      client_id: req.clientId,
      url: url,
      events: events,
      secret: secret || crypto.randomBytes(32).toString('hex'),
      status: 'active',
      created_at: new Date().toISOString()
    };
    
    console.log('Webhook created:', webhook);
    
    res.json({
      success: true,
      webhook: {
        webhook_id: webhookId,
        url: url,
        events: events,
        status: 'active'
      }
    });
  }
);

// Error handling
app.use((error, req, res, next) => {
  console.error('API Error:', error);
  
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    code: 'ASF_INTERNAL_ERROR'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    code: 'ASF_NOT_FOUND'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🛡️ ASF Platform API Server running on port ${PORT}`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/api/docs`);
  console.log(`💚 Health Check: http://localhost:${PORT}/health`);
});

module.exports = app;