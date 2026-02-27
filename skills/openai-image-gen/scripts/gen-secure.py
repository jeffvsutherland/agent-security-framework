#!/usr/bin/env python3
"""
Secure wrapper for OpenAI image generation
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
            return creds.get('openai_api_key', '')
    except:
        print("Error: Please store your OpenAI API key in ~/.openclaw/credentials.json", file=sys.stderr)
        print("Format: {\"openai_api_key\": \"your-key-here\"}", file=sys.stderr)
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

# Add only the OpenAI key temporarily
clean_env['OPENAI_API_KEY'] = api_key

# Find the original gen.py script
script_dir = os.path.dirname(os.path.abspath(__file__))
original_script = os.path.join("/app/skills/openai-image-gen/scripts/gen.py")

# Run original script with clean environment
result = subprocess.run([sys.executable, original_script] + sys.argv[1:], env=clean_env)
sys.exit(result.returncode)