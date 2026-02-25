# ASF-37: Spam Monitor Crontab Configuration
# Add to crontab with: crontab -e

# Moltbook Spam Monitor - every 5 minutes
*/5 * * * * ~/agent-security-framework/security-tools/moltbook-spam-monitor.sh --moltbook --report

# Gateway Spam Monitor - every 10 minutes  
*/10 * * * * ~/agent-security-framework/spam-reporting-infrastructure/gateway-spam-monitor.sh --all --notify

# Fake Agent Detector - every hour
0 * * * * ~/agent-security-framework/security-tools/fake-agent-detector.sh --full-scan --report

# Port Scan Detector - every hour
0 * * * * ~/agent-security-framework/security-tools/port-scan-detector.sh --daemon --log

# Infrastructure Security Check - daily at 2am
0 2 * * * ~/agent-security-framework/security-tools/infrastructure-security-check.sh --full --report

# Full YARA Scan - every 6 hours
0 */6 * * * ~/agent-security-framework/security-tools/asf-openclaw-scanner.py --yara --full

# Discord Alert Channel - real-time notifications
# Configure SLACK_WEBHOOK and DISCORD_WEBHOOK in ~/.asf/config

# To enable Discord alerts for spam, add to moltbook-spam-monitor.sh:
# export DISCORD_WEBHOOK="https://discord.com/api/webhooks/YOUR_WEBHOOK"
