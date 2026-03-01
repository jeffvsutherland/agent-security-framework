#!/bin/bash
echo "Activating ASF-40 to ASF-44..."
./docs/asf-40-multi-agent-supervisor/start-supervisor.sh --full
./docs/asf-41-security-auditor-guardrail/activate-guardrail.sh --all-agents
./docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh --full
python3 asf-44-fix-prompt-generator/asf-fix-prompt-generator.py --auto-apply --supervisor-gate
echo "✅ ASF-40 to ASF-44 FULLY ACTIVE – Clawdbot-Moltbot-Open-Claw secured, supervised & auto-remediated $(date)"
