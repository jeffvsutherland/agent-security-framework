/**
 * ASF Credential Theft Blocking Module for Node.js
 * Blocks attempts to access environment variables containing secrets
 */

const originalEnv = process.env;
const blockedPatterns = [
  'KEY', 'SECRET', 'TOKEN', 'PASSWORD', 'CREDENTIAL',
  'API_KEY', 'AUTH', 'PRIVATE', 'ACCESS_TOKEN',
  'GITHUB_TOKEN', 'OPENAI_API_KEY', 'ANTHROPIC_API_KEY'
];

// Blocked file paths
const blockedPaths = [
  '/root/.aws',
  '/root/.ssh',
  '/root/.config',
  '/home/',
  '/etc/passwd',
  '/etc/shadow',
  '/etc/security/'
];

// Block sensitive environment variables
Object.defineProperty(process, 'env', {
  get: () => {
    const env = {};
    for (const key in originalEnv) {
      const upperKey = key.toUpperCase();
      let blocked = false;
      for (const pattern of blockedPatterns) {
        if (upperKey.includes(pattern)) {
          blocked = true;
          break;
        }
      }
      if (!blocked) {
        env[key] = originalEnv[key];
      }
    }
    return env;
  },
  configurable: false
});

// Block file system access to sensitive paths
const originalReadFile = require('fs').readFile;
const originalReadFileSync = require('fs').readFileSync;
const fs = require('fs');

function checkPath(path) {
  for (const blocked of blockedPaths) {
    if (path.startsWith(blocked)) {
      throw new Error(`ASF Security: Blocked access to ${path}`);
    }
  }
}

const secureFs = new Proxy(fs, {
  get(target, prop) {
    if (['readFile', 'readFileSync', 'open', 'openSync', 'readdir', 'readdirSync'].includes(prop)) {
      return function(...args) {
        if (args[0]) checkPath(args[0]);
        return target[prop](...args);
      };
    }
    return target[prop];
  }
});

// Replace fs module for skill execution
Object.assign(global, { fs: secureFs });

console.log('[ASF Security] Node.js credential theft protection enabled');
