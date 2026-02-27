#!/usr/bin/env node
/**
 * ASF Secure Oracle Wrapper
 * Uses Clawdbot's auth system instead of environment variables
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Get the auth profile path from Clawdbot
const getAuthProfilePath = () => {
  // Clawdbot stores auth in agent-specific directories
  const agentDir = process.env.CLAWDBOT_AGENT_DIR || 
                   path.join(os.homedir(), '.clawdbot', 'agents', 'main', 'agent');
  return path.join(agentDir, 'auth-profiles.json');
};

// Read API key from secure storage
const getSecureApiKey = () => {
  try {
    const authPath = getAuthProfilePath();
    if (!fs.existsSync(authPath)) {
      console.error('❌ No auth profiles found. Run: clawdbot auth set openai api_key YOUR_KEY');
      process.exit(1);
    }

    const authData = JSON.parse(fs.readFileSync(authPath, 'utf8'));
    
    // Check for OpenAI credentials
    if (!authData.openai || !authData.openai.api_key) {
      console.error('❌ No OpenAI API key found in secure storage.');
      console.error('   Run: clawdbot auth set openai api_key YOUR_KEY');
      process.exit(1);
    }

    return authData.openai.api_key;
  } catch (error) {
    console.error('❌ Error reading secure credentials:', error.message);
    process.exit(1);
  }
};

// Main execution
const main = () => {
  console.log('🛡️  Oracle Secure: Using ASF credential management');
  
  // Get API key from secure storage
  const apiKey = getSecureApiKey();
  
  // Create new environment with the API key (only for oracle subprocess)
  const env = {
    ...process.env,
    OPENAI_API_KEY: apiKey
  };
  
  // Remove our wrapper from the path to avoid recursion
  delete env.CLAWDBOT_SKILL_PATH;
  
  // Run the actual oracle command with secure environment
  const oracle = spawn('oracle', process.argv.slice(2), {
    env,
    stdio: 'inherit'
  });

  oracle.on('error', (err) => {
    console.error('❌ Failed to run oracle:', err.message);
    process.exit(1);
  });

  oracle.on('exit', (code) => {
    process.exit(code || 0);
  });
};

// Run the secure wrapper
main();