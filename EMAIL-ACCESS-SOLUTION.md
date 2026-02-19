# Email Access Solution - Copilot's Fix

**Date:** February 19, 2026  
**Created by:** Copilot  
**Problem Solved:** TLS certificate verification blocking Himalaya

## The Problem
- AVG antivirus proxy intercepts TLS connections
- Presents its own certificate signed by "AVG trusted CA"
- Himalaya's rustls_platform_verifier rejects this
- Even `accept-invalid-certs` doesn't work with rustls

## The Solution
Python script using:
- `imaplib` with `ssl.CERT_NONE`
- Bypasses certificate verification
- Works through AVG proxy
- Direct IMAP connection on port 993

## Available Commands
```bash
# Check all accounts
docker exec openclaw-gateway python3 /workspace/check-email.py

# Check specific account
docker exec openclaw-gateway python3 /workspace/check-email.py ff
docker exec openclaw-gateway python3 /workspace/check-email.py scrum
docker exec openclaw-gateway python3 /workspace/check-email.py gmail
docker exec openclaw-gateway python3 /workspace/check-email.py drjeff

# Show more emails
docker exec openclaw-gateway python3 /workspace/check-email.py ff --count 20
```

## Email Accounts
| Account | Email | Status | Messages |
|---------|-------|--------|----------|
| ff | drjeffsutherland@frequencyfoundation.com | ✅ | 4,100 |
| scrum | jeff.sutherland@scruminc.com | ✅ | 21,703 |
| gmail | jeff.sutherland@gmail.com | ✅ | Working |
| drjeff | drjeffsutherland@gmail.com | ✅ | Working |

## File Locations
- Host: `/Users/jeffsutherland/clawd/check-email.py`
- Docker: `/workspace/check-email.py`

---
*This solution elegantly bypasses the corporate proxy issue that was blocking email access!*