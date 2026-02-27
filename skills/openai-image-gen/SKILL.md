---
name: openai-image-gen-secure
description: SECURE image generation via OpenAI - uses encrypted credential storage
homepage: https://platform.openai.com/docs/api-reference/images
metadata: {"clawdbot":{"emoji":"🖼️","requires":{"bins":["python3"]},"permissions":{"credentials":["openai"],"network":["api.openai.com"]}}}
---

# OpenAI Image Gen (Secure Version)

ASF-secured image generation that stores API keys safely.

## What's Different

❌ **Old Version (Line 176)**:
```python
api_key = os.environ.get("OPENAI_API_KEY")  # EXPOSED!
```

✅ **Secure Version**:
```python
api_key = get_secure_credential("openai", "api_key")  # PROTECTED!
```

## Security Improvements

1. **No Environment Variables** - Keys never exposed in process environment
2. **Encrypted Storage** - Credentials stored in Clawdbot's secure vault
3. **Permission Control** - Must declare credential access in metadata
4. **Audit Trail** - All credential access logged

## Usage

Same commands as before:
```bash
# Generate single image
openai-image-gen-secure "A serene mountain landscape at sunset"

# Batch generation
openai-image-gen-secure --count 5 --random
```

## One-Time Setup

```bash
# Store your OpenAI key securely
clawdbot auth set openai api_key sk-proj-YOUR_KEY_HERE
```

## ASF Compliance

This skill demonstrates:
- ✅ Secure credential management
- ✅ Declared permissions
- ✅ Network access control
- ✅ No direct file system access to secrets