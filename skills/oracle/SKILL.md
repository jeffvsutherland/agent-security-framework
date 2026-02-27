---
name: oracle-secure
description: SECURE version of oracle - uses proper credential management instead of environment variables
homepage: https://askoracle.dev
metadata: {"clawdbot":{"emoji":"🧿","requires":{"bins":["oracle"]},"permissions":{"credentials":["openai"]}}}
---

# Oracle (Secure Version)

This is the ASF-secured version of the oracle skill. It uses Clawdbot's auth profiles instead of reading OPENAI_API_KEY from the environment.

## What Changed

❌ **Old (Vulnerable)**:
- Reads OPENAI_API_KEY from environment
- Any malicious code could steal the key

✅ **New (Secure)**:
- Uses Clawdbot's auth.get() for credentials
- Key stored in encrypted auth profile
- Access controlled by permissions

## Setup

1. Store your OpenAI key securely:
```bash
clawdbot auth set openai api_key YOUR_KEY_HERE
```

2. The skill now automatically uses the secure credential store.

## Usage

All oracle commands work exactly the same:
```bash
oracle --engine browser --model gpt-5.2-pro -p "Your question" --file "src/**"
```

## Security Benefits

- API key never exposed in environment
- Credentials encrypted at rest
- Per-skill permission control
- Audit trail of credential access

This demonstrates ASF principle: **Secure by default, same functionality**