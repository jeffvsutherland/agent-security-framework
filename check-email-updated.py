#!/usr/bin/env python3
"""
Email checker for Docker container that bypasses TLS proxy verification (AVG).
This script works around the Himalaya TLS certificate issue.

Usage:
    python3 check-email.py                    # Check all accounts
    python3 check-email.py ff                 # Check specific account
    python3 check-email.py ff --count 10      # Show 10 recent emails
"""
import imaplib
import ssl
import sys
import argparse
from email.header import decode_header

# Email accounts configuration
ACCOUNTS = {
    "ff": {
        "email": "drjeffsutherland@frequencyfoundation.com",
        "password": "tmzmytqcjsepsvxz",
        "display_name": "Frequency Foundation"
    },
    "scrum": {
        "email": "jeff.sutherland@scruminc.com",
        "password": "ewxdzesqxloqllwq",
        "display_name": "Jeff Sutherland [Scrum Inc]"
    },
    "gmail": {
        "email": "jeff.sutherland@gmail.com",
        "password": "bmepgexdlwidmpbe",
        "display_name": "Jeff Sutherland Gmail"
    },
    "drjeff": {
        "email": "drjeffsutherland@gmail.com",
        "password": "xwfjdrsrpsxptduk",
        "display_name": "Dr Jeff Sutherland Gmail"
    },
    "saturday": {
        "email": "agent.saturday@scrumai.org",
        "password": "xmvuxcakcuohtuyk",
        "display_name": "Agent Saturday [ASF Product Owner]"
    },
    "scrumai": {
        "email": "jeff.sutherland@scrumai.org",
        "password": "ihcwmyutrtkqndei",
        "display_name": "Jeff Sutherland [ScrumAI]"
    }
}


def decode_mime_header(header):
    """Decode MIME encoded header"""
    if header is None:
        return ""
    decoded_parts = []
    for part, encoding in decode_header(header):
        if isinstance(part, bytes):
            decoded_parts.append(part.decode(encoding or "utf-8", errors="ignore"))
        else:
            decoded_parts.append(part)
    return "".join(decoded_parts)


def check_email(account_name, count=5):
    """Check email for a specific account"""
    if account_name not in ACCOUNTS:
        print(f"Unknown account: {account_name}")
        print(f"Available accounts: {', '.join(ACCOUNTS.keys())}")
        return False

    account = ACCOUNTS[account_name]

    # Create SSL context that doesn't verify certificates (for AVG/TLS proxy)
    context = ssl.create_default_context()
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE

    try:
        mail = imaplib.IMAP4_SSL("imap.gmail.com", 993, ssl_context=context)
        mail.login(account["email"], account["password"])
        mail.select("INBOX")

        # Get emails
        status, messages = mail.search(None, "ALL")
        email_ids = messages[0].split()

        print(f"  Account: {account_name} ({account['display_name']})")
        print(f"   Email: {account['email']}")
        print(f"   Total emails in INBOX: {len(email_ids)}")

        # Show recent emails
        if email_ids:
            print(f"\n   Recent {min(count, len(email_ids))} emails:")
            for eid in email_ids[-count:]:
                status, data = mail.fetch(eid, "(BODY[HEADER.FIELDS (FROM SUBJECT DATE)])")
                if data[0]:
                    header = data[0][1].decode("utf-8", errors="ignore")
                    lines = header.strip().split("\r\n")
                    from_addr = ""
                    subject = ""
                    date = ""
                    for line in lines:
                        if line.lower().startswith("from:"):
                            from_addr = decode_mime_header(line[5:].strip())
                        elif line.lower().startswith("subject:"):
                            subject = decode_mime_header(line[8:].strip())
                        elif line.lower().startswith("date:"):
                            date = line[5:].strip()[:20]
                    print(f"   - [{date}] {from_addr[:30]}: {subject[:50]}")

        mail.logout()
        print("   Connection successful\n")
        return True
    except Exception as e:
        print(f"   Error: {e}\n")
        return False


def main():
    parser = argparse.ArgumentParser(description="Check email accounts")
    parser.add_argument(
        "account",
        nargs="?",
        help="Account to check (ff, scrum, gmail, drjeff, saturday, scrumai, or all)",
    )
    parser.add_argument(
        "--count", "-c", type=int, default=5, help="Number of recent emails to show"
    )
    args = parser.parse_args()

    print("=" * 60)
    print("Email Checker (TLS Proxy Compatible)")
    print("=" * 60 + "\n")

    if args.account and args.account != "all":
        check_email(args.account, args.count)
    else:
        for account_name in ACCOUNTS:
            check_email(account_name, args.count)


if __name__ == "__main__":
    main()

