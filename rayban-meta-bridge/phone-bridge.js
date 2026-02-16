#!/usr/bin/env node
/**
 * Ray-Ban Meta Bridge for Clawdbot
 * Runs on phone to forward glasses data to Clawdbot
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class RayBanMetaBridge {
  constructor(config) {
    this.config = config;
    this.watchPaths = [
      // iOS Meta View paths
      '/var/mobile/Containers/Data/Application/*/Documents/Meta View/',
      '/var/mobile/Media/DCIM/',
      // Android paths
      '/sdcard/DCIM/Meta View/',
      '/sdcard/Pictures/Meta View/',
      '/storage/emulated/0/DCIM/Meta View/'
    ];
    this.processedFiles = new Set();
  }

  async start() {
    console.log('🕶️ Ray-Ban Meta Bridge Started');
    console.log(`📡 Connected to: ${this.config.gatewayUrl}`);
    
    // Start monitoring for new media
    this.startFileWatcher();
    
    // Start voice command listener
    this.startVoiceListener();
    
    // Health check
    setInterval(() => this.healthCheck(), 30000);
  }

  startFileWatcher() {
    // Watch for new photos/videos from glasses
    const checkInterval = 2000; // Check every 2 seconds
    
    setInterval(() => {
      this.watchPaths.forEach(watchPath => {
        this.checkForNewFiles(watchPath);
      });
    }, checkInterval);
  }

  checkForNewFiles(dirPath) {
    try {
      // Expand wildcards
      const dirs = this.expandPath(dirPath);
      
      dirs.forEach(dir => {
        if (!fs.existsSync(dir)) return;
        
        const files = fs.readdirSync(dir);
        files.forEach(file => {
          const fullPath = path.join(dir, file);
          const stats = fs.statSync(fullPath);
          
          // Check if new file (modified in last 5 seconds)
          const isNew = Date.now() - stats.mtimeMs < 5000;
          const isMedia = /\.(jpg|jpeg|png|mp4|mov)$/i.test(file);
          
          if (isNew && isMedia && !this.processedFiles.has(fullPath)) {
            this.processFile(fullPath);
            this.processedFiles.add(fullPath);
          }
        });
      });
    } catch (err) {
      // Silently continue - some paths may not exist
    }
  }

  expandPath(dirPath) {
    // Handle wildcard paths
    if (dirPath.includes('*')) {
      try {
        const result = execSync(`find ${dirPath} -type d 2>/dev/null`, { encoding: 'utf8' });
        return result.split('\n').filter(p => p);
      } catch {
        return [];
      }
    }
    return [dirPath];
  }

  async processFile(filePath) {
    console.log(`📸 New capture: ${path.basename(filePath)}`);
    
    const fileData = fs.readFileSync(filePath);
    const base64 = fileData.toString('base64');
    
    // Send to Clawdbot
    const command = {
      action: 'process_media',
      source: 'rayban-meta',
      type: filePath.endsWith('.mp4') || filePath.endsWith('.mov') ? 'video' : 'photo',
      filename: path.basename(filePath),
      data: base64,
      timestamp: new Date().toISOString(),
      metadata: {
        device: 'Ray-Ban Meta',
        size: fileData.length,
        path: filePath
      }
    };
    
    await this.sendToClawdbot(command);
  }

  async sendToClawdbot(command) {
    try {
      const response = await fetch(`${this.config.gatewayUrl}/api/nodes/command`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.config.nodeToken}`
        },
        body: JSON.stringify(command)
      });
      
      const result = await response.json();
      
      if (result.analysis) {
        this.speakResult(result.analysis);
      }
      
      console.log('✅ Sent to Clawdbot:', result);
    } catch (err) {
      console.error('❌ Failed to send:', err);
    }
  }

  speakResult(text) {
    // Use TTS to speak through phone (glasses will hear via Bluetooth)
    try {
      if (process.platform === 'darwin') {
        execSync(`say "${text}"`);
      } else if (process.platform === 'linux') {
        execSync(`espeak "${text}"`);
      }
      // On mobile, would use native TTS APIs
    } catch (err) {
      console.log('TTS not available');
    }
  }

  startVoiceListener() {
    // This would integrate with voice recognition
    // For now, using file monitoring as primary method
    console.log('🎤 Voice commands ready (via Meta View app)');
  }

  healthCheck() {
    // Send heartbeat to Clawdbot
    this.sendToClawdbot({ action: 'heartbeat', source: 'rayban-meta-bridge' });
  }
}

// Configuration
const config = {
  gatewayUrl: process.env.CLAWDBOT_GATEWAY || 'http://localhost:8180',
  nodeToken: process.env.CLAWDBOT_NODE_TOKEN || 'your-node-token',
  autoProcess: true
};

// Start the bridge
const bridge = new RayBanMetaBridge(config);
bridge.start().catch(console.error);