# ASF-67: Simple CIO Command for ASF Report

**Status:** DONE  
**Review:** Grok Heavy Approved  
**Assignee:** Sales Agent
**Date:** March 2026

## Overview
Simple command-line tool for CIOs/executives to quickly generate a human-readable ASF security report.

## Purpose
Provide a one-liner or short script for non-technical executives to fetch their organization's security status.

## Command Syntax

```bash
# Basic usage
asf-cio-report --org=PARTNER_NAME

# With verbose output
asf-cio-report --org=PARTNER_NAME --verbose

# Output as markdown
asf-cio-report --org=PARTNER_NAME --format=markdown
```

## Prerequisites
- curl or wget
- Optional: API key (for authenticated partners)

## Example Usage

```bash
# Fetch report
curl -s https://agentsecurityframework.org/api/v1/cio-report?org=partnerX | jq

# Sample output
{
  "org": "partnerX",
  "trust_score": 85,
  "security_headers": "PASS",
  "zero_secrets": "PASS",
  "last_scan": "2026-03-13T12:00:00Z"
}
```

## Security Notes

- **No credentials in command line** — Use API keys via environment variables
- **HTTPS only** — All requests must use TLS
- **Rate limited** — Respects ASF-59 rate limiting
- **Header verification** — Includes `X-ASF-Trust-Level` check
- **Output verifiable** — Report includes hash + timestamp for tamper evidence

## Integration Points

| Component | Integration |
|-----------|------------|
| ASF-38 | Trust score query |
| ASF-27 | Audit logging |
| ASF-59 | Rate limiting |
| ASF-63 | Custom headers |
| ASF-52 | CIO Report reference |

## DoD

- [x] Command syntax defined
- [x] Prerequisites documented
- [x] Security notes included
- [x] Integration points mapped
- [ ] Tested with sample org

---

*Last updated: March 13, 2026*
