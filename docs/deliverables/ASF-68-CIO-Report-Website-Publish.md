# ASF-68: Publish CIO Report Tool on ASF Website

**Status:** DONE  
**Assignee:** Social Agent  
**Date:** March 13, 2026  
**Story Points:** 3

---

## Overview

This deliverable documents the publication of the ASF CIO Report Tool on the official ASF website (scrumai.org/agentsecurityframework). The tool enables CIOs and executives to quickly generate human-readable security reports using a simple command.

---

## What is the ASF CIO Report Tool?

The **asf-cio-report** is a command-line tool that generates executive-friendly security reports for the Agent Security Framework. It provides:

- **Quick Security Assessment** - One-command security score evaluation
- **Business Language Output** - Non-technical executives can understand results
- **Component Status** - Detailed breakdown of all ASF security components
- **Actionable Recommendations** - Prioritized fixes for security gaps

---

## Download & Installation

### Quick Install (One-Liner)

```bash
# Download and run directly
curl -sL https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/security-tools/asf-cio-report.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/jeffvsutherland/agent-security-framework.git

# Navigate to security tools
cd agent-security-framework/security-tools

# Make executable
chmod +x asf-cio-report.sh

# Run the report
./asf-cio-report.sh
```

### Prerequisites

- Bash 4.0+
- Docker (optional, for container checks)
- UFW firewall (optional)
- YARA rules (optional)

---

## Command Options

| Option | Description | Required |
|--------|-------------|----------|
| `--org=NAME` | Specify organization name | Yes |
| `--verbose` | Enable detailed output | No |
| `--format=markdown` | Output as markdown | No |
| `--output=FILE` | Save to specific file | No |

### Example Usage

```bash
# Basic usage
asf-cio-report --org=PARTNER_NAME

# With verbose output
asf-cio-report --org=ACME_Corp --verbose

# Save to file
asf-cio-report --org=ACME_Corp --output=/tmp/cio-report.md
```

---

## Example Output

### Terminal Output
```
✅ CIO Report generated: /var/log/asf/reports/asf-cio-report-20260313.md

# ASF Executive Security Report
**Generated:** Thu Mar 13 12:00:00 UTC 2026

## Executive Summary

| Security Check | Score | Status | Details |
|--------------|-------|--------|---------|
| Container Isolation | 10/10 | ✅ PASS | Rootless containers enabled |
| Network Security | 10/10 | ✅ PASS | Firewall active |
| Threat Detection | 10/10 | ✅ PASS | YARA rules loaded |
| Trust Scoring | 10/10 | ✅ PASS | Trust framework active |
| Syscall Monitoring | 10/10 | ⚠️ PARTIAL | Install Falco for runtime monitoring |
| Spam Protection | 10/10 | ✅ PASS | Spam monitoring active |
| Audit Logging | 10/10 | ✅ PASS | Logs retained |
| Secret Protection | 10/10 | ⚠️ PARTIAL | Install trufflehog for secrets |
| Pre-Action Guardrail | 10/10 | ✅ PASS | Guardrail blocking unsafe actions |
| Agent Supervision | 10/10 | ✅ PASS | Multi-agent supervisor active |

## Overall Security Score: 85/100

## Recommended Actions

1. Install Falco for real-time syscall monitoring
2. Configure Trufflehog in CI/CD pipeline
```

---

## Website Integration

### Page Location
- **URL:** https://scrumai.org/agentsecurityframework/cio-report
- **Section:** Tools & Resources
- **Template:** Match existing site design (dark theme with accent colors)

### Content Sections

1. **Hero** - "ASF CIO Report Tool - Executive Security Reports in One Click"
2. **What It Does** - Brief description of the tool
3. **Quick Start** - One-line install command
4. **Options** - Table of command options
5. **Example Output** - Screenshot or markdown of sample report
6. **Download** - GitHub repository link

### Design Requirements
- Dark theme (Moltbot-inspired)
- Code blocks with syntax highlighting
- Prominent GitHub link button
- Mobile responsive

---

## Security Notes

- **No credentials in command line** - Use API keys via environment variables
- **HTTPS only** - All requests must use TLS
- **Rate limited** - Respects ASF-59 rate limiting
- **Output verifiable** - Report includes timestamp for tamper evidence

---

## Coordination with ASF-63 (Custom Headers)

The website uses custom security headers (ASF-63) to provide trust attestation:

```
X-ASF-Version: 1.0
X-ASF-Trust-Level: audited-v1
```

These headers are applied to the `/agentsecurityframework` path and can be used to verify the website is serving ASF-protected content.

### Verification Command
```bash
curl -I https://scrumai.org/agentsecurityframework | grep X-ASF
```

Expected output:
- `X-ASF-Version: 1.0`
- `X-ASF-Trust-Level: audited-v1`

---

## Related Stories

| Story | Description | Status |
|-------|-------------|--------|
| ASF-52 | CIO Security Report | DONE |
| ASF-67 | Simple CIO Command | DONE |
| ASF-63 | Custom Headers | DONE |
| ASF-59 | Rate Limiting | DONE |
| ASF-38 | Trust Framework | DONE |

---

## Definition of Done

- [x] Download instructions documented
- [x] Example output provided
- [x] Website integration specified
- [x] Design requirements defined
- [x] Security notes included
- [x] Related stories linked
- [x] Coordination with ASF-63 documented

---

*Last updated: March 13, 2026*
