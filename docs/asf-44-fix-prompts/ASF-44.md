# ASF-44: Fix Prompt Generator

## Clawdbot-Moltbot-Open-Claw Specific

| Failing Component | Example Problem | Fix Prompt | Ties To |
|-----------------|-----------------|------------|----------|
| Clawdbot WhatsApp | Exposed port | nftables rule | ASF-35 |
| Moltbot PC-control | Unsafe capability | --cap-drop ALL | ASF-42 |
| Open-Claw skills | Low-trust skill | Quarantine | ASF-38 |
| Supervisor | Syscall violation | Restart + log | ASF-40 |

## Usage

```bash
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate
```

## DoD

- [ ] Integrates with bootup scan
- [ ] Generates fix prompts
- [ ] No secrets in output
