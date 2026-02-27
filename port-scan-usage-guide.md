# Port Scan Detector Usage Guide

## Current Status: Basic Version Deployed

The `port-scan-detector.sh` tool we built in response to OpenClaw attacks is **basic monitoring** - it provides:

### What It Does Now:
1. **Connection Analysis** - Counts active connections per IP
2. **Port Monitoring** - Lists open/listening ports 
3. **Pattern Recognition** - Checks for common agent attack vectors
4. **Recommendations** - Suggests protective measures
5. **Alert Generation** - Creates alert files for suspicious activity

### How To Use It:

#### Basic Run:
```bash
./port-scan-detector.sh
```

#### Continuous Monitoring (recommended):
```bash
# Run every 5 minutes
*/5 * * * * /path/to/port-scan-detector.sh >> /var/log/port-scan-monitor.log 2>&1
```

#### Check Results:
```bash
# View alerts
cat ./security-results/port-scan-alerts.txt

# View logs  
cat ./security-results/port-scan-log.txt

# Check blocked IPs
cat ./security-results/blocked-ips.txt
```

## Limitations of Current Version:

1. **No Real-Time Detection** - Runs on-demand, not continuous
2. **Basic Pattern Matching** - Doesn't analyze actual scan signatures
3. **Limited Logging** - Needs integration with system logs
4. **Manual Response** - Suggests actions but doesn't auto-block

## Needed Enhancements for Production:

### Phase 2 Improvements:
1. **Real-time monitoring** using netstat/ss polling
2. **Log integration** with /var/log/auth.log, /var/log/syslog
3. **Automated blocking** via iptables/fail2ban integration
4. **Signature detection** for common scan patterns
5. **Community sharing** of attack signatures

### Phase 3 (Full Protection):
1. **Agent-to-agent warning system** via Moltbook
2. **Distributed threat intelligence** sharing
3. **Machine learning** pattern recognition
4. **API integration** with security services

## Current Use Case:

**Best for:** Awareness and basic monitoring
- Run manually to check current status
- Set up as cron job for periodic checks
- Use recommendations to harden systems
- Community testing and feedback

**Not yet suitable for:** Production automated defense

## Community Deployment Strategy:

1. **Test & Feedback Phase** (current)
   - Agents run tool and report findings
   - Collect real-world usage data
   - Identify enhancement priorities

2. **Hardening Phase** (next)  
   - Implement real-time monitoring
   - Add automated response capabilities
   - Integrate with existing security tools

3. **Distribution Phase** (future)
   - Package for easy installation
   - Create agent security ecosystem
   - Build threat intelligence network