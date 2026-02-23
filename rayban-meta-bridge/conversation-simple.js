#!/usr/bin/env node
/**
 * Simple Ray-Ban Meta Conversation Mode
 * Enables dialogue with Clawdbot through glasses
 */

const readline = require('readline');
const { exec } = require('child_process');
const http = require('http');

class GlassesConversation {
  constructor(gatewayUrl = 'http://localhost:8180', token = '') {
    this.gatewayUrl = gatewayUrl;
    this.token = token;
    this.sessionKey = null;
    this.isActive = false;
    
    // For text input
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
  }

  async start() {
    console.log('🕶️ Ray-Ban Meta Conversation Mode');
    console.log('=================================');
    console.log('');
    
    // Start session
    this.sessionKey = 'glasses-' + Date.now();
    this.isActive = true;
    
    this.speak("Hello! I'm connected through your glasses. What can I help you with?");
    console.log('\n💬 Type your message (or "exit" to quit)');
    console.log('   Voice mode: Install speech recognition npm packages\n');
    
    // Start conversation loop
    this.conversationLoop();
  }

  async conversationLoop() {
    while (this.isActive) {
      const input = await this.getUserInput();
      
      if (!input || input.toLowerCase() === 'exit') {
        this.speak("Goodbye!");
        this.isActive = false;
        break;
      }
      
      // Handle special commands
      if (this.handleCommand(input)) {
        continue;
      }
      
      // Send to Clawdbot
      const response = await this.sendToClawdbot(input);
      if (response) {
        console.log(`\n🤖 Clawdbot: ${response}`);
        this.speak(response);
      }
    }
    
    this.rl.close();
  }

  getUserInput() {
    return new Promise((resolve) => {
      this.rl.question('You: ', (input) => {
        resolve(input);
      });
    });
  }

  handleCommand(input) {
    const lower = input.toLowerCase();
    
    if (lower.includes('take a photo') || lower.includes('take photo')) {
      console.log('📸 [Simulating photo capture through glasses]');
      this.speak("Taking a photo. I'll analyze it when it syncs.");
      // In real implementation, trigger Meta View app
      return true;
    }
    
    if (lower.includes('what do you see') || lower.includes('what am i looking at')) {
      console.log('👀 [Analyzing last photo]');
      this.speak("Let me analyze what you're looking at...");
      setTimeout(() => {
        this.speak("I see a development environment with code on the screen. Looks like you're working on a Node.js project.");
      }, 2000);
      return true;
    }
    
    if (lower.includes('remember this')) {
      const memory = input.replace(/remember this:?/i, '').trim();
      console.log(`🧠 [Saving to memory: ${memory}]`);
      this.speak(`I'll remember: ${memory}`);
      return true;
    }
    
    return false;
  }

  async sendToClawdbot(message) {
    return new Promise((resolve) => {
      const data = JSON.stringify({
        message: message,
        session_key: this.sessionKey,
        source: 'rayban-meta-conversation'
      });

      const options = {
        hostname: this.gatewayUrl.replace(/https?:\/\//, '').split(':')[0],
        port: this.gatewayUrl.split(':')[2] || 80,
        path: '/api/chat',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': data.length,
          'Authorization': `Bearer ${this.token}`
        }
      };

      const req = http.request(options, (res) => {
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
          try {
            const response = JSON.parse(body);
            resolve(response.message || response.response || 'No response');
          } catch (e) {
            // Fallback responses for demo
            resolve(this.getFallbackResponse(message));
          }
        });
      });

      req.on('error', (e) => {
        console.error(`❌ Connection error: ${e.message}`);
        resolve(this.getFallbackResponse(message));
      });

      req.write(data);
      req.end();
    });
  }

  getFallbackResponse(message) {
    // Simple responses for testing without gateway
    const lower = message.toLowerCase();
    
    if (lower.includes('weather')) {
      return "It's currently 72°F and sunny. Perfect weather for wearing your Ray-Bans!";
    }
    if (lower.includes('time')) {
      return `It's ${new Date().toLocaleTimeString()}.`;
    }
    if (lower.includes('hello') || lower.includes('hi')) {
      return "Hello! How can I help you today?";
    }
    if (lower.includes('meeting')) {
      return "You have a 2pm design review and 4pm sync with the team.";
    }
    
    return "I understand. Let me help you with that through your glasses.";
  }

  speak(text) {
    // Text-to-speech through phone speaker (heard in glasses via Bluetooth)
    console.log(`\n🔊 Speaking: "${text}"`);
    
    if (process.platform === 'darwin') {
      // macOS
      exec(`say "${text}"`);
    } else if (process.platform === 'linux') {
      // Linux/Android
      exec(`espeak "${text}" 2>/dev/null || echo "TTS not available"`);
    }
    // On actual phone, would use native TTS APIs
  }
}

// Main execution
if (require.main === module) {
  const gatewayUrl = process.env.CLAWDBOT_GATEWAY || 'http://localhost:8180';
  const token = process.env.CLAWDBOT_TOKEN || 'your-token';
  
  console.log('Starting Ray-Ban Meta conversation bridge...');
  console.log(`Gateway: ${gatewayUrl}`);
  console.log('');
  
  const conversation = new GlassesConversation(gatewayUrl, token);
  conversation.start().catch(console.error);
}

module.exports = GlassesConversation;