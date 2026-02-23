# ASF YARA Rules for Agent Skill Security

## Overview

These YARA rules detect credential theft patterns, obfuscated code, and suspicious network calls in agent skills. They are specifically designed to catch malicious behaviors including the known credential stealer from @Rufio.

## Rules Included

### 1. **ASF_SSH_Key_Access**
- Detects attempts to access SSH private keys
- Catches both direct paths and obfuscated variants
- Severity: Critical

### 2. **ASF_AWS_Credential_Access**
- Detects AWS credential theft attempts
- Identifies AWS key patterns and config access
- Severity: Critical

### 3. **ASF_Environment_Variable_Theft**
- Detects reading of sensitive environment variables
- Catches API keys, tokens, and secrets
- Severity: High

### 4. **ASF_DotEnv_File_Access**
- Detects attempts to read .env files
- Specifically includes Clawdbot/OpenClaw paths
- Severity: Critical

### 5. **ASF_Credential_Search_Commands**
- Detects commands that search for credential files
- Catches `find`, `locate`, `grep` patterns
- Severity: High

### 6. **ASF_Data_Exfiltration**
- Detects network-based data exfiltration
- Identifies webhook sites and encoding attempts
- Severity: Critical

### 7. **ASF_Code_Obfuscation**
- Detects obfuscated code patterns
- Catches eval, exec, and encoded payloads
- Severity: Medium

### 8. **ASF_Suspicious_Network_Operations**
- Detects reverse shells and network scanning
- Identifies C2 server patterns
- Severity: High

### 9. **ASF_Clawdbot_Specific_Attacks**
- Detects Clawdbot/OpenClaw specific credential theft
- Targets platform-specific paths and variables
- Severity: Critical

### 10. **ASF_Combined_Credential_Theft**
- Combined detection rule
- Matches the exact pattern used by @Rufio's credential stealer
- Severity: Critical

## Installation

### Prerequisites
```bash
# Install YARA (Ubuntu/Debian)
sudo apt-get install yara

# Install YARA (macOS)
brew install yara

# Install Python bindings (optional)
pip install yara-python
```

### Download Rules
```bash
# Clone or download the YARA rules
curl -O https://raw.githubusercontent.com/ASF/yara-rules/main/asf_credential_theft.yara
```

## Usage

### Command Line Scanning

```bash
# Scan a single file
yara asf_credential_theft.yara suspicious_skill.py

# Scan a directory recursively
yara -r asf_credential_theft.yara /path/to/skills/

# Scan with detailed output
yara -s asf_credential_theft.yara target_file

# Scan and show only matching files
yara -c asf_credential_theft.yara /path/to/skills/
```

### Integration with ASF Scanner

```python
import yara

# Compile YARA rules
rules = yara.compile(filepath='asf_credential_theft.yara')

# Scan a file
def scan_file(filepath):
    matches = rules.match(filepath)
    if matches:
        print(f"DANGER: {filepath} matched rules:")
        for match in matches:
            print(f"  - {match.rule}: {match.meta['description']}")
    return matches

# Scan skill directory
def scan_skill(skill_path):
    dangerous = False
    for root, dirs, files in os.walk(skill_path):
        for file in files:
            filepath = os.path.join(root, file)
            if scan_file(filepath):
                dangerous = True
    return dangerous
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: YARA Security Scan
  run: |
    sudo apt-get update
    sudo apt-get install -y yara
    yara -r asf_credential_theft.yara ./skills/
    if [ $? -ne 0 ]; then
      echo "Security scan failed!"
      exit 1
    fi
```

## Testing the Rules

### Test Against Known Malicious Code

```bash
# Test against the @Rufio credential stealer
yara asf_credential_theft.yara malicious_python.py

# Expected output:
ASF_SSH_Key_Access malicious_python.py
ASF_AWS_Credential_Access malicious_python.py
ASF_Environment_Variable_Theft malicious_python.py
ASF_Combined_Credential_Theft malicious_python.py
```

### Create Test Cases

```python
# test_benign.py - Should NOT trigger
def read_config():
    with open('config.json', 'r') as f:
        return json.load(f)

# test_malicious.py - Should trigger multiple rules
import os
ssh_key = open(os.path.expanduser("~/.ssh/id_rsa")).read()
aws_creds = open(os.path.expanduser("~/.aws/credentials")).read()
api_key = os.environ.get('OPENAI_API_KEY')
```

## Rule Tuning

### Reducing False Positives

If experiencing false positives, you can:

1. **Adjust rule conditions** - Require multiple patterns:
```yara
rule ASF_High_Confidence_Theft {
    condition:
        2 of (ASF_SSH_Key_Access, ASF_AWS_Credential_Access, 
              ASF_Environment_Variable_Theft, ASF_Data_Exfiltration)
}
```

2. **Add whitelisting** - Exclude known safe patterns:
```yara
rule ASF_SSH_Key_Access {
    strings:
        $whitelist1 = "# Example SSH key path"
        $whitelist2 = "documentation"
    condition:
        any of ($ssh*) and not any of ($whitelist*)
}
```

3. **Context-aware detection** - Check file types:
```yara
rule ASF_Python_Credential_Theft {
    condition:
        ASF_SSH_Key_Access and 
        (filename matches /\.py$/ or 
         uint32(0) == 0x2123212F)  // #!/ shebang
}
```

## Performance Considerations

- **File size limits**: YARA performs well on files < 100MB
- **Rule complexity**: More strings = slower scanning
- **Optimization**: Use `fast` mode for initial scans:
  ```bash
  yara -f asf_credential_theft.yara large_directory/
  ```

## Maintenance

### Updating Rules

1. Monitor for new attack patterns
2. Add patterns as they're discovered:
```yara
$new_pattern = "~/.new_app/credentials" nocase
```

3. Test updates against known samples
4. Version control all changes

### Rule Versioning

```yara
rule ASF_Credential_Theft_v2 {
    meta:
        version = "2.0"
        last_updated = "2026-02-21"
        changelog = "Added detection for new_app credentials"
```

## Support

For questions or to report new patterns:
- Create issue in ASF GitHub repository
- Contact ASF team in Discord/Telegram
- Email: security@agentsecurityframework.com

## License

These YARA rules are part of the Agent Security Framework and are released under the MIT License.

---

**Remember**: Security is a continuous process. Keep your rules updated and scan regularly!

## Security Hardening Checklist

- [x] Git ignore test samples and IOCs
- [x] Rules compiled and validated
- [ ] Integration into skill install flow
- [ ] Daily cron/launchd scanning enabled
- [ ] Weekly rule rotation schedule

## Weekly Rule Update Process

```bash
# Every Monday - Pull latest IOCs and update rules
cd ~/clawd/agent-security-framework
git pull origin main
yara -c docs/asf-5-yara-rules/*.yara
# Test against samples
# Deploy to production
```

## Integration

See [DOCKER-INTEGRATION.md](./DOCKER-INTEGRATION.md) for:
- Docker volume mounts
- Skill install hooks
- Daily cron scanning
- macOS LaunchAgent setup