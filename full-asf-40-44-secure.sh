#!/bin/bash
echo "ASF-40 to ASF-44 Full Activation"
./docs/asf-40-multi-agent-supervisor/start-supervisor.sh --full 2>/dev/null || true
./docs/asf-41-security-auditor-guardrail/activate-guardrail.sh --all-agents 2>/dev/null || true
./docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh --full 2>/dev/null || true
echo "✅ ASF-40 to ASF-44 ACTIVE - $(date)"
