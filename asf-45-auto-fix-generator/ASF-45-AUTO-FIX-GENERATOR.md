# ASF-45: Automated Security Fix Prompt Generator

## Overview
Integrates with ASF-44 bootup scan. Generates prompts for each failing security layer.

## Layers
| Layer | Fix Focus |
|-------|-----------|
| Layer 1: Skills | Quarantine + YARA |
| Layer 2: Config | Rotate secrets |
| Layer 3: Container | Dockerfile hardening |
| Layer 4: Network | nftables |
| Layer 5: Runtime | Restart + log |
| Layer 6: Trust | Quarantine + review |

## Usage
python3 asf-45-auto-fix-generator.py --input scan-results.json
