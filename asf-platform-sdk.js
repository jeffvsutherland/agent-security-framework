/**
 * ASF Platform SDK - Node.js Client Library
 * Provides easy integration with ASF Platform API for agent verification
 */

const https = require('https');
const crypto = require('crypto');
const { EventEmitter } = require('events');

class ASFPlatformSDK extends EventEmitter {
  constructor(options = {}) {
    super();
    
    this.apiKey = options.apiKey || process.env.ASF_API_KEY;
    this.environment = options.environment || 'production';
    this.baseUrl = options.baseUrl || this.getBaseUrl();
    this.timeout = options.timeout || 10000;
    this.retries = options.retries || 3;
    
    // Caching options
    this.cache = options.cache || { enabled: false };
    this.cacheStore = new Map();
    
    // Rate limiting
    this.rateLimit = options.rateLimit || { enabled: false };
    this.requestQueue = [];
    this.isRateLimited = false;
    
    if (!this.apiKey) {
      throw new Error('ASF API key is required');
    }
    
    if (!this.apiKey.startsWith('asf_')) {
      throw new Error('Invalid ASF API key format');
    }
  }
  
  getBaseUrl() {
    switch (this.environment) {
      case 'production':
        return 'https://api.asf.security/v1';
      case 'staging':
        return 'https://staging-api.asf.security/v1';
      case 'testing':
        return 'https://test-api.asf.security/v1';
      case 'local':
        return 'http://localhost:3000/api';
      default:
        throw new Error(`Unknown environment: ${this.environment}`);
    }
  }
  
  /**
   * Make HTTP request to ASF API
   */
  async makeRequest(method, endpoint, data = null) {
    const url = `${this.baseUrl}${endpoint}`;
    
    const options = {
      method: method,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        'User-Agent': 'ASF-Platform-SDK/1.0.0'
      },
      timeout: this.timeout
    };
    
    let attempt = 0;
    
    while (attempt < this.retries) {
      try {
        const response = await this._httpRequest(url, options, data);
        return response;
      } catch (error) {
        attempt++;
        
        if (error.code === 'ASF_RATE_LIMIT' && attempt < this.retries) {
          await this._delay(error.retryAfter * 1000);
          continue;
        }
        
        if (attempt >= this.retries) {
          throw error;
        }
        
        // Exponential backoff for retries
        await this._delay(Math.pow(2, attempt) * 1000);
      }
    }
  }
  
  /**
   * Internal HTTP request implementation
   */
  _httpRequest(url, options, data) {
    return new Promise((resolve, reject) => {
      const req = https.request(url, options, (res) => {
        let body = '';
        
        res.on('data', (chunk) => {
          body += chunk;
        });
        
        res.on('end', () => {
          try {
            const jsonBody = JSON.parse(body);
            
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(jsonBody);
            } else {
              const error = new Error(jsonBody.error || 'Request failed');
              error.code = jsonBody.code;
              error.statusCode = res.statusCode;
              error.retryAfter = res.headers['retry-after'];
              reject(error);
            }
          } catch (parseError) {
            reject(new Error('Invalid JSON response'));
          }
        });
      });
      
      req.on('error', (error) => {
        reject(error);
      });
      
      req.on('timeout', () => {
        req.abort();
        reject(new Error('Request timeout'));
      });
      
      if (data) {
        req.write(JSON.stringify(data));
      }
      
      req.end();
    });
  }
  
  /**
   * Delay helper for retries and rate limiting
   */
  _delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  /**
   * Cache helper functions
   */
  _getCacheKey(method, endpoint, data) {
    const key = `${method}:${endpoint}:${JSON.stringify(data || {})}`;
    return crypto.createHash('sha256').update(key).digest('hex');
  }
  
  _getFromCache(cacheKey) {
    if (!this.cache.enabled) return null;
    
    const cached = this.cacheStore.get(cacheKey);
    if (!cached) return null;
    
    if (Date.now() > cached.expires) {
      this.cacheStore.delete(cacheKey);
      return null;
    }
    
    return cached.data;
  }
  
  _setCache(cacheKey, data, ttl = 3600) {
    if (!this.cache.enabled) return;
    
    this.cacheStore.set(cacheKey, {
      data: data,
      expires: Date.now() + (ttl * 1000)
    });
  }
  
  /**
   * Verify single agent authenticity
   */
  async verifyAgent(agentId, options = {}) {
    if (!agentId) {
      throw new Error('Agent ID is required');
    }
    
    const requestData = {
      agent_id: agentId,
      platform: options.platform || 'unknown',
      context: options.context || {}
    };
    
    // Check cache first
    const cacheKey = this._getCacheKey('POST', '/verify/agent', requestData);
    const cached = this._getFromCache(cacheKey);
    if (cached && options.useCache !== false) {
      return cached.verification;
    }
    
    try {
      const response = await this.makeRequest('POST', '/verify/agent', requestData);
      
      // Cache successful responses
      if (response.success && options.useCache !== false) {
        this._setCache(cacheKey, response, options.cacheTtl || 1800);
      }
      
      this.emit('verification_completed', {
        agent_id: agentId,
        result: response.verification
      });
      
      return response.verification;
      
    } catch (error) {
      this.emit('verification_failed', {
        agent_id: agentId,
        error: error.message
      });
      
      throw error;
    }
  }
  
  /**
   * Batch verify multiple agents
   */
  async verifyBatch(agents, options = {}) {
    if (!Array.isArray(agents) || agents.length === 0) {
      throw new Error('Agents array is required and must not be empty');
    }
    
    const requestData = {
      agents: agents,
      options: {
        include_details: options.includeDetails !== false,
        async: options.async || false
      }
    };
    
    try {
      const response = await this.makeRequest('POST', '/verify/batch', requestData);
      
      this.emit('batch_verification_completed', {
        batch_id: response.batch_id,
        summary: response.summary
      });
      
      return response;
      
    } catch (error) {
      this.emit('batch_verification_failed', {
        agents: agents,
        error: error.message
      });
      
      throw error;
    }
  }
  
  /**
   * Get agent certification status
   */
  async getCertification(agentId) {
    if (!agentId) {
      throw new Error('Agent ID is required');
    }
    
    // Check cache first
    const cacheKey = this._getCacheKey('GET', `/certification/${agentId}`);
    const cached = this._getFromCache(cacheKey);
    if (cached) {
      return cached.certification;
    }
    
    try {
      const response = await this.makeRequest('GET', `/certification/${agentId}`);
      
      // Cache certification data for longer (they don't change often)
      this._setCache(cacheKey, response, 7200); // 2 hours
      
      return response.certification;
      
    } catch (error) {
      if (error.code === 'ASF_CERT_NOT_FOUND' || error.code === 'ASF_AGENT_NOT_CERTIFIED') {
        return null; // Agent not certified
      }
      throw error;
    }
  }
  
  /**
   * Assess agent risk level
   */
  async assessRisk(agentId, evidence = {}) {
    if (!agentId) {
      throw new Error('Agent ID is required');
    }
    
    const requestData = {
      agent_id: agentId,
      evidence: evidence
    };
    
    try {
      const response = await this.makeRequest('POST', '/assess/risk', requestData);
      
      this.emit('risk_assessment_completed', {
        agent_id: agentId,
        risk_level: response.risk_assessment.overall_risk
      });
      
      return response.risk_assessment;
      
    } catch (error) {
      this.emit('risk_assessment_failed', {
        agent_id: agentId,
        error: error.message
      });
      
      throw error;
    }
  }
  
  /**
   * Submit community vouch
   */
  async submitVouch(voucherId, targetId, reason, evidence = {}) {
    if (!voucherId || !targetId || !reason) {
      throw new Error('Voucher ID, target ID, and reason are required');
    }
    
    const requestData = {
      voucher_id: voucherId,
      target_id: targetId,
      reason: reason,
      evidence: evidence
    };
    
    try {
      const response = await this.makeRequest('POST', '/vouch/submit', requestData);
      
      this.emit('vouch_submitted', {
        voucher_id: voucherId,
        target_id: targetId,
        vouch_id: response.vouch.vouch_id
      });
      
      return response.vouch;
      
    } catch (error) {
      this.emit('vouch_failed', {
        voucher_id: voucherId,
        target_id: targetId,
        error: error.message
      });
      
      throw error;
    }
  }
  
  /**
   * Get dashboard analytics
   */
  async getDashboardAnalytics(timeRange = '24h') {
    const cacheKey = this._getCacheKey('GET', '/dashboard/analytics', { time_range: timeRange });
    const cached = this._getFromCache(cacheKey);
    if (cached) {
      return cached;
    }
    
    try {
      const response = await this.makeRequest('GET', `/dashboard/analytics?time_range=${timeRange}`);
      
      // Cache analytics for shorter time (they update frequently)
      this._setCache(cacheKey, response, 600); // 10 minutes
      
      return response;
      
    } catch (error) {
      throw error;
    }
  }
  
  /**
   * Create webhook subscription
   */
  async createWebhook(webhookUrl, events, secret = null) {
    if (!webhookUrl || !Array.isArray(events)) {
      throw new Error('Webhook URL and events array are required');
    }
    
    const requestData = {
      url: webhookUrl,
      events: events,
      secret: secret
    };
    
    try {
      const response = await this.makeRequest('POST', '/webhooks', requestData);
      
      this.emit('webhook_created', {
        webhook_id: response.webhook.webhook_id,
        url: webhookUrl
      });
      
      return response.webhook;
      
    } catch (error) {
      this.emit('webhook_creation_failed', {
        url: webhookUrl,
        error: error.message
      });
      
      throw error;
    }
  }
  
  /**
   * Verify webhook signature (for incoming webhooks)
   */
  verifyWebhookSignature(payload, signature, secret) {
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(payload)
      .digest('hex');
    
    return crypto.timingSafeEqual(
      Buffer.from(signature, 'hex'),
      Buffer.from(expectedSignature, 'hex')
    );
  }
  
  /**
   * Bulk operations helper
   */
  async bulkVerify(agentIds, options = {}) {
    if (!Array.isArray(agentIds)) {
      throw new Error('Agent IDs must be an array');
    }
    
    const batchSize = options.batchSize || 50;
    const parallel = options.parallel || 5;
    const results = [];
    
    // Split into batches
    const batches = [];
    for (let i = 0; i < agentIds.length; i += batchSize) {
      batches.push(agentIds.slice(i, i + batchSize));
    }
    
    // Process batches with limited parallelism
    for (let i = 0; i < batches.length; i += parallel) {
      const batchPromises = [];
      
      for (let j = 0; j < parallel && (i + j) < batches.length; j++) {
        const batch = batches[i + j];
        const agents = batch.map(id => ({ agent_id: id, platform: options.platform }));
        
        batchPromises.push(this.verifyBatch(agents, options));
      }
      
      const batchResults = await Promise.allSettled(batchPromises);
      
      for (const result of batchResults) {
        if (result.status === 'fulfilled') {
          results.push(...result.value.results);
        } else if (!options.failFast) {
          console.error('Batch failed:', result.reason);
        } else {
          throw result.reason;
        }
      }
    }
    
    return results;
  }
  
  /**
   * Helper method to get agent badge HTML
   */
  getAgentBadgeHtml(certification, options = {}) {
    if (!certification) {
      return options.showUnverified ? '<span class="asf-badge asf-unverified">⚠️ Unverified</span>' : '';
    }
    
    const badges = {
      'CERTIFIED': { emoji: '💎', color: '#FFD700', text: 'Certified' },
      'AUTHENTICATED': { emoji: '🔷', color: '#9932CC', text: 'Authenticated' },
      'VERIFIED': { emoji: '🔹', color: '#4169E1', text: 'Verified' },
      'BASIC': { emoji: '✅', color: '#32CD32', text: 'Basic' }
    };
    
    const badge = badges[certification.level];
    if (!badge) return '';
    
    const style = options.style || 'inline';
    const showScore = options.showScore !== false;
    
    if (style === 'full') {
      return `
        <div class="asf-badge asf-badge-full" style="border-left: 4px solid ${badge.color}; padding: 8px; margin: 4px 0; background: #f8f9fa;">
          <strong style="color: ${badge.color};">${badge.emoji} ${certification.level}</strong>
          <div style="font-size: 0.9em; color: #666;">
            ASF ${badge.text} Agent
            ${showScore ? ` | Score: ${certification.authenticity_score || 0}/100` : ''}
            ${certification.verification_url ? ` | <a href="${certification.verification_url}" target="_blank">Verify</a>` : ''}
          </div>
        </div>
      `;
    } else {
      return `
        <span class="asf-badge asf-badge-inline" 
              style="color: ${badge.color}; font-weight: bold;" 
              title="ASF ${badge.text} Certification${showScore ? ` | Score: ${certification.authenticity_score || 0}/100` : ''}">
          ${badge.emoji}
        </span>
      `;
    }
  }
}

// Export the SDK class
module.exports = ASFPlatformSDK;

// Example usage (if run directly)
if (require.main === module) {
  async function example() {
    try {
      const asf = new ASFPlatformSDK({
        apiKey: 'asf_demo_key_123',
        environment: 'local',
        cache: { enabled: true }
      });
      
      // Listen to events
      asf.on('verification_completed', (data) => {
        console.log('✅ Verification completed:', data);
      });
      
      asf.on('verification_failed', (data) => {
        console.log('❌ Verification failed:', data);
      });
      
      // Example: Verify single agent
      console.log('Verifying AgentSaturday...');
      const verification = await asf.verifyAgent('AgentSaturday', {
        platform: 'moltbook',
        context: { 
          recent_posts: 5,
          engagement_rate: 0.85
        }
      });
      
      console.log('Verification result:', verification);
      
      // Example: Check certification
      console.log('\\nChecking certification...');
      const certification = await asf.getCertification('AgentSaturday');
      
      if (certification) {
        console.log('Certification:', certification);
        
        // Generate badge HTML
        const badgeHtml = asf.getAgentBadgeHtml(certification, { style: 'full' });
        console.log('Badge HTML:', badgeHtml);
      } else {
        console.log('No certification found');
      }
      
      // Example: Batch verification
      console.log('\\nBatch verification...');
      const batchResult = await asf.verifyBatch([
        { agent_id: 'AgentSaturday', platform: 'moltbook' },
        { agent_id: 'SecurityResearcher', platform: 'github' },
        { agent_id: 'BasicAgent', platform: 'discord' }
      ]);
      
      console.log('Batch results:', batchResult.summary);
      
    } catch (error) {
      console.error('Example failed:', error.message);
    }
  }
  
  // Run example if API server is available
  example();
}