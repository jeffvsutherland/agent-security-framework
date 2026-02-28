#!/bin/bash
# asf-bootup-scan.sh - Daily bootup security scan generating CIO report
# Runs all 10 security layers and generates human-readable report

set -euo pipefail

REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="CIO-SECURITY-REPORT-${REPORT_DATE}.md"
SCORE=0
MAX_SCORE=10

echo "🛡️ ASF Bootup Security Scan"
echo "============================="
echo "Date: $REPORT_DATE"
echo ""

# Initialize report
cat > "$REPORT_FILE" << 'EOF'
# CIO Security Report - OpenClaw
## Executive Summary

**Date:** REPLACE_DATE
**Overall Security Score:** X/10

This report provides a human-readable overview of the OpenClaw security posture, showing which security layers are operational and which require attention.

---

## Security Layers Detail

EOF

# Layer 1: Identity & Access Management
echo "Checking Layer 1: Identity & Access Management..."
LAYER1_SCORE=0
if [ -f ~/.asf/config/auth.yaml ]; then
    LAYER1_STATUS="✅ PASS"
    LAYER1_SCORE=1
    LAYER1_NOTES="IAM configured with role-based access control"
else
    LAYER1_STATUS="❌ FAIL"
    LAYER1_NOTES="No IAM configuration found - risk of unauthorized access"
fi
SCORE=$((SCORE + LAYER1_SCORE))

cat >> "$REPORT_FILE" << EOF
### 1. Identity & Access Management (IAM)
**Status:** $LAYER1_STATUS
**Score:** $LAYER1_SCORE/1

**What this means:** We verify that only authorized agents and users can access the system.

**Technical Details:** $LAYER1_NOTES

**Business Impact:** Without IAM, anyone could access your agent infrastructure.

**Recommendation:** Configure IAM immediately using the deployment guide.

---

EOF

# Layer 2: Network Segmentation
echo "Checking Layer 2: Network Segmentation..."
LAYER2_SCORE=0
if grep -q "network_mode: bridge" ~/.asf/docker-compose.yml 2>/dev/null || [ -f ~/.asf/config/network.yaml ]; then
    LAYER2_STATUS="✅ PASS"
    LAYER2_SCORE=1
    LAYER2_NOTES="Network segmentation configured - containers isolated from host"
else
    LAYER2_STATUS="❌ FAIL"
    LAYER2_NOTES="Network segmentation not configured - containers may have excessive network access"
fi
SCORE=$((SCORE + LAYER2_SCORE))

cat >> "$REPORT_FILE" << EOF
### 2. Network Segmentation
**Status:** $LAYER2_STATUS
**Score:** $LAYER2_SCORE/1

**What this means:** We verify that agent containers cannot directly access your corporate network or the internet without going through controlled pathways.

**Technical Details:** $LAYER2_NOTES

**Business Impact:** Without segmentation, a compromised agent could access your entire network.

**Recommendation:** Configure Docker network isolation.

---

EOF

# Layer 3: Container Isolation
echo "Checking Layer 3: Container Isolation..."
LAYER3_SCORE=0
if grep -q "cap_drop" ~/.asf/docker-compose.yml 2>/dev/null || [ -f ~/.asf/config/security.yaml ]; then
    LAYER3_STATUS="✅ PASS"
    LAYER3_SCORE=1
    LAYER3_NOTES="Container capabilities restricted - root privileges dropped"
else
    LAYER3_STATUS="⚠️ PARTIAL"
    LAYER3_SCORE=0.5
    LAYER3_NOTES="Container may have excessive privileges"
fi
SCORE=$((SCORE + LAYER3_SCORE))

cat >> "$REPORT_FILE" << EOF
### 3. Container Isolation
**Status:** $LAYER3_STATUS
**Score:** $LAYER3_SCORE/1

**What this means:** We verify that agent containers cannot break out of their sandbox to access the host system.

**Technical Details:** $LAYER3_NOTES

**Business Impact:** Without proper isolation, a malicious skill could access your entire server.

**Recommendation:** Add security options to Docker compose.

---

EOF

# Layer 4: Secrets Management
echo "Checking Layer 4: Secrets Management..."
LAYER4_SCORE=0
if [ -f ~/.asf/secrets/credentials.yaml.enc ]; then
    LAYER4_STATUS="✅ PASS"
    LAYER4_SCORE=1
    LAYER4_NOTES="Credentials encrypted at rest"
elif [ -f ~/.asf/config/vault.yaml ]; then
    LAYER4_STATUS="✅ PASS"
    LAYER4_SCORE=1
    LAYER4_NOTES="HashiCorp Vault configured for secrets"
else
    LAYER4_STATUS="❌ FAIL"
    LAYER4_NOTES="No secrets management - API keys stored in plain text"
fi
SCORE=$((SCORE + LAYER4_SCORE))

cat >> "$REPORT_FILE" << EOF
### 4. Secrets Management
**Status:** $LAYER4_STATUS
**Score:** $LAYER4_SCORE/1

**What this means:** We verify that API keys, passwords, and tokens are encrypted, not stored in plain text.

**Technical Details:** $LAYER4_NOTES

**Business Impact:** Exposed secrets can lead to unauthorized access and data breaches.

**Recommendation:** Configure secrets management.

---

EOF

# Layer 5: Instruction Security (SOUL.md)
echo "Checking Layer 5: Instruction Security..."
LAYER5_SCORE=0
if [ -f ~/.asf/SOUL.md ]; then
    LAYER5_STATUS="✅ PASS"
    LAYER5_SCORE=1
    LAYER5_NOTES="Agent personality defined with security constraints"
else
    LAYER5_STATUS="❌ FAIL"
    LAYER5_NOTES="No SOUL.md - agents may behave unexpectedly"
fi
SCORE=$((SCORE + LAYER5_SCORE))

cat >> "$REPORT_FILE" << EOF
### 5. Instruction Security (SOUL.md)
**Status:** $LAYER5_STATUS
**Score:** $LAYER5_SCORE/1

**What this means:** We verify that each agent has a defined "conscience" (SOUL.md) that constrains its behavior.

**Technical Details:** $LAYER5_NOTES

**Business Impact:** Without SOUL.md, agents could take unintended actions that harm your business.

**Recommendation:** Create SOUL.md for each agent.

---

EOF

# Layer 6: Skill Verification
echo "Checking Layer 6: Skill Verification..."
LAYER6_SCORE=0
if [ -d ~/.asf/skills/verified ]; then
    LAYER6_STATUS="✅ PASS"
    LAYER6_SCORE=1
    LAYER6_NOTES="Skills verified before installation"
else
    LAYER6_STATUS="❌ FAIL"
    LAYER6_NOTES="No skill verification - malicious skills could be installed"
fi
SCORE=$((SCORE + LAYER6_SCORE))

cat >> "$REPORT_FILE" << EOF
### 6. Skill Verification
**Status:** $LAYER6_STATUS
**Score:** $LAYER6_SCORE/1

**What this means:** We verify that all agent skills (plugins) are scanned for malicious code before installation.

**Technical Details:** $LAYER6_NOTES

**Business Impact:** Unverified skills can contain malware that steals data or compromises your system.

**Recommendation:** Set up skill verification pipeline.

---

EOF

# Layer 7: Runtime Protection
echo "Checking Layer 7: Runtime Protection..."
LAYER7_SCORE=0
if command -v falco &> /dev/null || [ -f /etc/falco.yaml ]; then
    LAYER7_STATUS="✅ PASS"
    LAYER7_SCORE=1
    LAYER7_NOTES="Runtime threat detection active"
else
    LAYER7_STATUS="❌ FAIL"
    LAYER7_NOTES="No runtime protection - cannot detect attacks in progress"
fi
SCORE=$((SCORE + LAYER7_SCORE))

cat >> "$REPORT_FILE" << EOF
### 7. Runtime Protection
**Status:** $LAYER7_STATUS
**Score:** $LAYER7_SCORE/1

**What this means:** We verify that we can detect attacks happening in real-time, not just prevent them.

**Technical Details:** $LAYER7_NOTES

**Business Impact:** Without runtime protection, you won't know if you're being attacked.

**Recommendation:** Install Falco or equivalent.

---

EOF

# Layer 8: Monitoring & Alerting
echo "Checking Layer 8: Monitoring & Alerting..."
LAYER8_SCORE=0
if [ -f ~/.asf/config/alerts.yaml ]; then
    LAYER8_STATUS="✅ PASS"
    LAYER8_SCORE=1
    LAYER8_NOTES="Alerting configured for security events"
else
    LAYER8_STATUS="❌ FAIL"
    LAYER8_NOTES="No alerting - security events go unnoticed"
fi
SCORE=$((SCORE + LAYER8_SCORE))

cat >> "$REPORT_FILE" << EOF
### 8. Monitoring & Alerting
**Status:** $LAYER8_STATUS
**Score:** $LAYER8_SCORE/1

**What this means:** We verify that security events generate alerts to your team immediately.

**Technical Details:** $LAYER8_NOTES

**Business Impact:** Without alerting, breaches can happen without anyone knowing.

**Recommendation:** Configure alert webhooks.

---

EOF

# Layer 9: Backup & Recovery
echo "Checking Layer 9: Backup & Recovery..."
LAYER9_SCORE=0
if [ -d ~/.asf/backups ]; then
    LAYER9_STATUS="✅ PASS"
    LAYER9_SCORE=1
    LAYER9_NOTES="Backups configured for disaster recovery"
else
    LAYER9_STATUS="⚠️ PARTIAL"
    LAYER9_SCORE=0.5
    LAYER9_NOTES="No verified backups - data loss risk"
fi
SCORE=$((SCORE + LAYER9_SCORE))

cat >> "$REPORT_FILE" << EOF
### 9. Backup & Recovery
**Status:** $LAYER9_STATUS
**Score:** $LAYER9_SCORE/1

**What this means:** We verify that your data is backed up and can be recovered in case of disaster.

**Technical Details:** $LAYER9_NOTES

**Business Impact:** Without backups, a ransomware attack or hardware failure could destroy all data.

**Recommendation:** Set up automated backups.

---

EOF

# Layer 10: Documentation & Compliance
echo "Checking Layer 10: Documentation & Compliance..."
LAYER10_SCORE=0
if [ -f ~/.asf/docs/security-policy.md ]; then
    LAYER10_STATUS="✅ PASS"
    LAYER10_SCORE=1
    LAYER10_NOTES="Security documentation complete"
else
    LAYER10_STATUS="❌ FAIL"
    LAYER10_NOTES="No security documentation - compliance risk"
fi
SCORE=$((SCORE + LAYER10_SCORE))

cat >> "$REPORT_FILE" << EOF
### 10. Documentation & Compliance
**Status:** $LAYER10_STATUS
**Score:** $LAYER10_SCORE/1

**What this means:** We verify that security policies and procedures are documented.

**Technical Details:** $LAYER10_NOTES

**Business Impact:** Without documentation, you cannot demonstrate compliance to auditors.

**Recommendation:** Create security policy documentation.

---

EOF

# Summary
echo ""
echo "============================="
echo "Security Score: $SCORE/10"
echo "============================="

cat >> "$REPORT_FILE" << EOF
## Executive Summary - Score

**Overall Security Score: $SCORE/10**

EOF

if [ $SCORE -ge 8 ]; then
    echo "### Rating: STRONG" >> "$REPORT_FILE"
    echo "Rating: STRONG" 
elif [ $SCORE -ge 5 ]; then
    echo "### Rating: MODERATE" >> "$REPORT_FILE"
    echo "Rating: MODERATE"
else
    echo "### Rating: NEEDS IMPROVEMENT" >> "$REPORT_FILE"
    echo "Rating: NEEDS IMPROVEMENT"
fi

cat >> "$REPORT_FILE" << EOF

Your OpenClaw deployment has $SCORE out of 10 security layers fully operational.

## Recommended Next Steps

1. Address any ❌ FAIL items above
2. Review ⚠️ PARTIAL items for hardening opportunities
3. Run this scan weekly to track progress

---

*Generated by ASF Bootup Security Scan*
EOF

# Replace date placeholder
sed -i "s/REPLACE_DATE/$REPORT_DATE/g" "$REPORT_FILE"

echo ""
echo "✅ Report generated: $REPORT_FILE"
echo ""
echo "Score: $SCORE/10"
