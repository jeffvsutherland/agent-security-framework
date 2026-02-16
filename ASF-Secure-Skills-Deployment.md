# ASF Secure Skills Deployment Guide

## 🛡️ Securing Our Own Clawdbot

We're practicing what we preach - securing the vulnerable skills in our own installation.

## 🔴 Current Vulnerabilities

### Oracle
- **Location**: `/opt/homebrew/lib/node_modules/clawdbot/skills/oracle/`
- **Vulnerability**: Reads OPENAI_API_KEY from environment
- **Risk**: Any malicious code can steal the key

### OpenAI-Image-Gen  
- **Location**: `/opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen/`
- **Vulnerability**: Line 176: `api_key = os.environ.get("OPENAI_API_KEY")`
- **Risk**: Same as Moltbook breach - exposed credentials

## ✅ Secure Replacements

### Step 1: Install Secure Versions

```bash
# Copy secure skills to Clawdbot skills directory
cd ~/clawd
cp -r asf-secure-skills/oracle-secure /opt/homebrew/lib/node_modules/clawdbot/skills/
cp -r asf-secure-skills/openai-image-gen-secure /opt/homebrew/lib/node_modules/clawdbot/skills/

# Make scripts executable
chmod +x /opt/homebrew/lib/node_modules/clawdbot/skills/oracle-secure/scripts/oracle-secure.js
chmod +x /opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen-secure/scripts/gen-secure.py
```

### Step 2: Migrate Credentials

```bash
# Remove API key from environment
unset OPENAI_API_KEY

# Store in Clawdbot's secure vault
clawdbot auth set openai api_key sk-proj-YOUR_ACTUAL_KEY_HERE

# Verify it's stored
clawdbot auth list
```

### Step 3: Update Skill References

In your Clawdbot configuration or when using skills:

```bash
# Old (vulnerable)
oracle --model gpt-5.2-pro -p "question"
openai-image-gen "prompt"

# New (secure)
oracle-secure --model gpt-5.2-pro -p "question"  
openai-image-gen-secure "prompt"
```

### Step 4: Remove Vulnerable Versions (Optional)

Once verified working:
```bash
# Backup first
mv /opt/homebrew/lib/node_modules/clawdbot/skills/oracle /opt/homebrew/lib/node_modules/clawdbot/skills/oracle.vulnerable
mv /opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen /opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen.vulnerable

# Or rename secure versions to replace
mv /opt/homebrew/lib/node_modules/clawdbot/skills/oracle-secure /opt/homebrew/lib/node_modules/clawdbot/skills/oracle
mv /opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen-secure /opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen
```

## 🔍 Verification

### Test Oracle
```bash
# Should use secure credentials
oracle-secure --dry-run -p "test" --file README.md

# Check no environment exposure
env | grep OPENAI  # Should be empty
```

### Test Image Generation
```bash
# Generate test image
openai-image-gen-secure "A secure lock protecting API keys"

# Verify credential access logged
tail ~/.clawdbot/agent.log  # Should show secure access
```

## 📊 Security Improvements

| Aspect | Before | After |
|--------|--------|-------|
| API Key Storage | Environment variable | Encrypted auth profile |
| Key Exposure Risk | Any process can read | Only authorized skills |
| Credential Rotation | Manual env update | `clawdbot auth set` |
| Access Logging | None | Full audit trail |
| Permission Control | None | Declared in metadata |

## 🚀 Benefits

1. **Immediate Protection** - No more exposed API keys
2. **Same Functionality** - All features work identically  
3. **ASF Demonstration** - Shows we secure our own tools
4. **Best Practice Example** - Template for securing other skills

## 📝 Notes

- Secure versions are drop-in replacements
- No changes needed to how you use the skills
- Credentials now managed centrally via `clawdbot auth`
- Can extend this pattern to any skill using environment variables

## 🎯 Result

**Before**: Same vulnerabilities that exposed 1.5M tokens at Moltbook
**After**: ASF-compliant secure credential management

This is ASF in action - not just finding vulnerabilities, but fixing them!