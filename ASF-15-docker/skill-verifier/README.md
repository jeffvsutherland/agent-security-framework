# ASF Skill Security Verification System

A comprehensive security checker for OpenClaw/ClawHub skills, protecting against malicious code and credential theft.

## Features

- **Pattern Analysis**: Detects credential theft, obfuscation, and dangerous commands
- **External Connection Monitoring**: Identifies suspicious outbound connections
- **Dependency Scanning**: Checks npm dependencies for known malicious packages
- **VirusTotal Integration**: Optional malware scanning via VirusTotal API
- **Discord Bot**: Automated verification in Discord channels
- **Caching**: 24-hour result caching to reduce redundant scans

## Components

### 1. skill-checker.sh
Bash script that performs deep security analysis:
- Extracts skills from GitHub, npm, zip, or local sources
- Scans for suspicious patterns (credential theft, obfuscation, etc.)
- Checks for dangerous commands and external URLs
- Integrates with VirusTotal for malware detection
- Generates detailed JSON reports

### 2. discord-skill-bot.js
Discord bot for automated skill verification:
- Responds to `!checkskill` commands
- Auto-detects skill URLs in messages
- Provides risk assessment with visual indicators
- Caches results for 24 hours

## Installation

1. Clone the repository:
```bash
cd /path/to/ASF-15-docker/skill-verifier
```

2. Install dependencies:
```bash
npm install
```

3. Make the checker script executable:
```bash
chmod +x skill-checker.sh
```

4. Set up environment variables:
```bash
cp ../.env.example .env
# Edit .env with your tokens:
# - DISCORD_SKILL_BOT_TOKEN
# - DISCORD_SKILL_CHECKER_CHANNEL_ID
# - VIRUSTOTAL_API_KEY (optional)
```

5. Create Discord bot:
   - Go to https://discord.com/developers/applications
   - Create new application
   - Go to Bot section, create bot
   - Copy token to .env file
   - Invite bot to your server with "Send Messages" and "Read Message History" permissions

## Usage

### Command Line
```bash
# Check a GitHub skill
./skill-checker.sh https://github.com/openclaw/skill-weather

# Check a local directory
./skill-checker.sh /path/to/skill

# Check a zip file
./skill-checker.sh my-skill.zip
```

### Discord Bot
```bash
# Start the bot
npm start

# In Discord:
!checkskill https://github.com/openclaw/skill-weather
!check @openclaw/skill-email
!help
```

## Security Patterns Detected

### High Risk (DO NOT INSTALL)
- Credential theft (SSH, AWS, API keys)
- Obfuscated/encoded payloads
- Cryptocurrency exchange APIs
- System destruction commands
- Known malware signatures

### Medium Risk (Review Carefully)
- External URL connections
- Base64 encoded content
- Executable shell scripts
- Missing SKILL.md file
- Uncommon npm dependencies

### Low Risk (Appears Safe)
- No suspicious patterns found
- Only connects to known safe domains
- Standard skill structure
- No obfuscation

## Risk Assessment

The system uses a three-tier risk model:

- 🟢 **LOW**: Safe to install
- 🟡 **MEDIUM**: Review code before installing
- 🔴 **HIGH**: Do not install, contains malicious patterns

## Integration with ASF

This skill verifier integrates with the Agent Security Framework to:
1. Prevent installation of malicious skills
2. Audit existing skills in the ecosystem
3. Provide automated verification for skill marketplaces
4. Enable community-driven security reporting

## Example Output

```
🛡️ ASF Skill Security Check
==========================
📦 Extracting skill...
🔍 Analyzing skill: skill-weather
  Scanning for suspicious patterns...
  🦠 Checking with VirusTotal...
  ✅ VirusTotal: Clean
  ✅ LOW RISK - Appears safe

📄 Full report saved to: ./skill-verification-results/skill-weather-security-report.json

📊 Summary:
  Risk Level: low
  Threats: 0
  Recommendation: Appears safe
```

## Contributing

To add new security patterns:
1. Edit the patterns in `skill-checker.sh`
2. Test against known malicious skills
3. Submit PR with explanation of pattern

## Security Considerations

- Never run untrusted skills without sandboxing
- Always review HIGH/MEDIUM risk skills manually
- Keep VirusTotal API key secure
- Run verifier in isolated environment
- Update patterns regularly as new threats emerge

## Based On

- OpenClaw Security Guide
- VirusTotal API
- OWASP dependency scanning practices
- Community-reported malicious patterns

## License

MIT License - Part of the Agent Security Framework (ASF)