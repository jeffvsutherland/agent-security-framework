#!/usr/bin/env python3
"""
Secure wrapper for Nano Banana Pro (Gemini) image generation
Blocks environment variable access while maintaining functionality
"""
import subprocess
import sys
import os
import json

# Load API key from secure storage
def get_api_key():
    cred_file = os.path.expanduser("~/.openclaw/credentials.json")
    try:
        with open(cred_file, 'r') as f:
            creds = json.load(f)
            return creds.get('gemini_api_key', '')
    except:
        print("Error: Please store your Gemini API key in ~/.openclaw/credentials.json", file=sys.stderr)
        print("Format: {\"gemini_api_key\": \"your-key-here\"}", file=sys.stderr)
        return None

# Get API key from secure storage
api_key = get_api_key()
if not api_key:
    sys.exit(1)

# Create clean environment without sensitive variables
clean_env = os.environ.copy()

# Remove ALL API keys from environment
keys_to_remove = [k for k in clean_env.keys() if 'API' in k or 'KEY' in k or 'SECRET' in k or 'TOKEN' in k]
for key in keys_to_remove:
    clean_env.pop(key, None)

# Add only the Gemini key temporarily
clean_env['GEMINI_API_KEY'] = api_key

# Find the original script
original_script = "/app/skills/nano-banana-pro/scripts/generate_image.py"

# Run original script with clean environment
result = subprocess.run([sys.executable, original_script] + sys.argv[1:], env=clean_env)
sys.exit(result.returncode)