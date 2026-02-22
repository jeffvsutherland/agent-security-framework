#!/usr/bin/env python3
"""Fix OpenClaw config: remove invalid keys causing crash loop, keep MiniMax as primary"""
import json, sys

# Read from the fixed config that has providers removed from model entries
input_path = '/tmp/oc-cfg-minimax-fixed.json'
output_path = '/tmp/oc-cfg-clean-final.json'

with open(input_path) as f:
    cfg = json.load(f)

# FIX 1: Remove "providers" key from agents.defaults (invalid key)
if 'providers' in cfg.get('agents', {}).get('defaults', {}):
    del cfg['agents']['defaults']['providers']
    print("REMOVED: agents.defaults.providers")

# FIX 2: Remove "provider" key from any model config (already done but double-check)
models = cfg.get('agents', {}).get('defaults', {}).get('models', {})
for name in list(models.keys()):
    if 'provider' in models[name]:
        del models[name]['provider']
        print(f"REMOVED: provider from {name}")

# Verify primary model
primary = cfg['agents']['defaults']['model']['primary']
print(f"Primary model: {primary}")
print(f"Gateway bind: {cfg.get('gateway', {}).get('bind', '?')}")
print(f"Has providers key: {'providers' in cfg['agents']['defaults']}")

# List all model configs
for name, mcfg in models.items():
    print(f"  Model {name}: keys={list(mcfg.keys())}")

with open(output_path, 'w') as f:
    json.dump(cfg, f, indent=2)

print(f"\nSaved clean config to {output_path}")

