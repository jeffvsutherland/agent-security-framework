# Email Access for Agents

## Available Email Accounts (Himalaya)

| Account Name | Email Address | Command |
|-------------|---------------|---------|
| `frequencyfoundation` | drjeffsutherland@frequencyfoundation.com | `himalaya envelope list -a frequencyfoundation` |
| `main` | jeff.sutherland@gmail.com | `himalaya envelope list -a main` |
| `scruminc` | jeff.sutherland@scruminc.com | `himalaya envelope list -a scruminc` |
| `drjeff` | drjeffsutherland@gmail.com | `himalaya envelope list -a drjeff` |

## Common Commands

### List Recent Emails
```bash
himalaya envelope list -a frequencyfoundation --page-size 10
```

### Read a Specific Email
```bash
himalaya message read -a frequencyfoundation <ID>
```

### Send an Email
```bash
himalaya message write -a frequencyfoundation
```

### Search Emails
```bash
himalaya envelope list -a frequencyfoundation --query "subject:invoice"
```

## Troubleshooting

If you get authentication errors:
1. The app passwords are stored in macOS Keychain
2. Check the keychain entry: `security find-generic-password -s himalaya-frequencyfoundation -a drjeffsutherland@frequencyfoundation.com -w`
3. Config file: `~/.config/himalaya/config.toml`

## For Frequency Foundation Email Specifically

The account `drjeffsutherland@frequencyfoundation.com` uses:
- IMAP: imap.gmail.com:993
- SMTP: smtp.gmail.com:465
- Auth: Google App Password (stored in Keychain as `himalaya-frequencyfoundation`)

