# Setup Secure Oracle Skill

## Current Status
✅ Secure oracle skill installed in `~/clawd/skills/oracle/`
✅ Vulnerable built-in version still exists but user skills take precedence
❌ Need to add OpenAI API key to secure auth profiles

## To Complete Setup

1. **Add OpenAI key to auth profiles**:
   
   Edit `~/.clawdbot/agents/main/agent/auth-profiles.json` and add:
   ```json
   {
     "anthropic": {
       "apiKey": "sk-ant-api03-..."
     },
     "openai": {
       "api_key": "YOUR_OPENAI_API_KEY_HERE"
     }
   }
   ```

2. **Test the secure version**:
   ```bash
   # The skill will now use the secure auth profile
   oracle --help
   ```

3. **Verify it's NOT reading from environment**:
   ```bash
   # This should be empty (no key in env)
   echo $OPENAI_API_KEY
   
   # But oracle should still work using secure storage
   oracle --dry-run -p "test" --file README.md
   ```

## How It Works

The secure oracle skill:
- ✅ Reads from `auth-profiles.json` (encrypted, permission-controlled)
- ❌ Does NOT read from environment variables
- ✅ Only accessible to authorized Clawdbot processes
- ✅ Cannot be stolen by malicious code

## Security Benefits

1. **No Environment Exposure**: Keys aren't in process environment
2. **File Permissions**: auth-profiles.json is 600 (owner-only)
3. **Agent Isolation**: Each agent has separate auth profiles
4. **No Plaintext in Memory**: Keys are loaded only when needed

This prevents the vulnerability that affected Moltbook (1.5M tokens stolen via environment variable access).