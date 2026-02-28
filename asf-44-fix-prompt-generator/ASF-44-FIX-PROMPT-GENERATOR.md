# ASF-44: Agent Fix Prompt Generator

## Overview

Automated system to generate prompts that agents can use to apply security fixes based on scan results.

## How It Works

1. Run CIO security scan → Get findings
2. Generate remediation prompts → Agents execute fixes
3. Verify fixes → Update report

## Integration with CIO Report

The generator reads `ASF-CIO-SECURITY-REPORT.md` and creates actionable prompts for each failing component.

## Usage

```bash
# Generate fix prompts from CIO report
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md

# Generate and auto-apply
python3 asf-fix-prompt-generator.py --auto-apply
```

## Prompt Templates

### For Each Failing Component:

```
## Fix: [Component Name]

### Problem
[Brief description of what's failing]

### Fix Command
[Exact command to run]

### Verification
[How to confirm fix worked]
```

## Example Output

### Fix: YARA Rules Update

**Problem:** YARA rules need updating to detect new threats

**Fix Command:**
```bash
cd ~/agent-security-framework
git pull origin main
python3 docs/asf-5-yara-rules/update-rules.py
```

**Verification:**
```bash
yara -r docs/asf-5-yara-rules/ ~/.openclaw/skills/ | head
```

## Integration

- Works with ASF-CIO-SECURITY-REPORT.md
- Generates prompts for ASF-38, ASF-41, ASF-42, ASF-40
- Outputs to FIX-PROMPTS.md

## Acceptance Criteria

- [ ] Reads CIO report
- [ ] Generates prompts for each failing component
- [ ] Includes verification steps
- [ ] Can auto-apply fixes
