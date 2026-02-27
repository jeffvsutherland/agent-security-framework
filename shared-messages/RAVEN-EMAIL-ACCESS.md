# 📧 Email Access for Raven (Product Owner Agent)

**Quick Reference - How to Check Email**

---

## 🚀 Quick Commands

### Check Agent Saturday Email
```bash
python3 /workspace/check-email.py scrum
```

### Check All Email Accounts
```bash
python3 /workspace/check-email.py
```

### Check Specific Accounts
```bash
# Frequency Foundation
python3 /workspace/check-email.py ff

# Scrum Inc (includes agent.saturday@scrumai.org)
python3 /workspace/check-email.py scrum

# Personal Gmail
python3 /workspace/check-email.py gmail

# Dr Jeff Gmail
python3 /workspace/check-email.py drjeff
```

### See More Emails (increase count)
```bash
# Show 10 recent emails
python3 /workspace/check-email.py scrum --count 10

# Show 20 recent emails
python3 /workspace/check-email.py ff --count 20
```

---

## 📋 Available Email Accounts

| Short Name | Email Address | Description | Total Emails |
|------------|---------------|-------------|--------------|
| `scrum` | jeff.sutherland@scruminc.com<br>agent.saturday@scrumai.org | Scrum Inc & Agent Saturday | ~21,703 |
| `ff` | drjeffsutherland@frequencyfoundation.com | Frequency Foundation | ~4,100 |
| `gmail` | jeff.sutherland@gmail.com | Personal Gmail | Working |
| `drjeff` | drjeffsutherland@gmail.com | Dr Jeff Gmail | Working |

**Note:** The `scrum` account includes emails sent to **agent.saturday@scrumai.org** - this is your primary Agent Saturday email!

---

## 🎯 Common Use Cases

### Morning Email Check
```bash
# Check Agent Saturday emails
python3 /workspace/check-email.py scrum --count 10
```

### Search for Specific Sender
```bash
# The script shows From, Subject, and Date
# Read output to find emails from specific people
python3 /workspace/check-email.py scrum --count 20
```

### Check Multiple Accounts
```bash
# Check all accounts at once
python3 /workspace/check-email.py

# Or check them individually
python3 /workspace/check-email.py scrum
python3 /workspace/check-email.py ff
```

---

## 📍 File Locations

**Script Location:**
- **Host:** `/Users/jeffsutherland/clawd/check-email.py`
- **Docker:** `/workspace/check-email.py` ← Use this path in commands

**From Your Perspective (Docker Container):**
```bash
# You're inside the openclaw-gateway container
# Use: /workspace/check-email.py
```

---

## 🔧 Technical Details

### Why This Script Instead of Himalaya?
- Himalaya has TLS certificate issues with the AVG antivirus proxy
- This Python script bypasses certificate verification
- Works reliably through the network proxy

### What the Script Shows
For each email:
- **From:** Sender's name and email
- **Subject:** Email subject line
- **Date:** When it was received

### Output Example
```
Account: scrum (jeff.sutherland@scruminc.com)
Total emails: 21703
Last 5 emails:

From: John Doe <john@example.com>
Subject: Sprint Planning Meeting
Date: Mon, 23 Feb 2026 14:30:00 +0000
---
```

---

## ⚠️ Important Notes

1. **Agent Saturday Email:** Lives in the `scrum` account
   - Use: `python3 /workspace/check-email.py scrum`

2. **Default Shows 5 Emails:** Use `--count N` to see more

3. **Run from Docker:** You're inside the container, so just use the command directly:
   ```bash
   python3 /workspace/check-email.py scrum
   ```

4. **No Need for docker exec:** That's only needed when running from outside the container

---

## 🆘 Troubleshooting

### "File not found"
- Make sure you're using the full path: `/workspace/check-email.py`
- Script is mounted from host `~/clawd/` directory

### "Connection error"
- The script bypasses TLS verification to work through AVG proxy
- Should work even with network security tools

### "Account not found"
- Valid accounts: `ff`, `scrum`, `gmail`, `drjeff`
- Or run without arguments to check all accounts

---

## 📞 Quick Reference Card

```
┌─────────────────────────────────────────────┐
│  🔥 MOST COMMON COMMAND                     │
├─────────────────────────────────────────────┤
│  Check Agent Saturday email:                │
│  python3 /workspace/check-email.py scrum \  │
│    --count 10                               │
│                                             │
│  Check all accounts:                        │
│  python3 /workspace/check-email.py          │
│                                             │
│  Check specific account:                    │
│  python3 /workspace/check-email.py [NAME]   │
│    Options: scrum, ff, gmail, drjeff        │
└─────────────────────────────────────────────┘
```

---

**Created:** February 23, 2026
**Status:** ✅ All accounts working
**Last Tested:** February 19, 2026

---

**📧 Happy emailing, Raven!**
