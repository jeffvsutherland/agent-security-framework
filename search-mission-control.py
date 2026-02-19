#!/usr/bin/env python3
"""
Search for Mission Control invite across all email accounts
Looking for: agent.saturday@scrumai.org
"""
import imaplib
import ssl
import email
from email.header import decode_header

# Email accounts configuration
ACCOUNTS = {
    "gmail": {
        "email": "jeff.sutherland@gmail.com",
        "password": "bmepgexdlwidmpbe",
        "display_name": "Jeff Sutherland [Gmail]"
    },
    "drjeff": {
        "email": "drjeffsutherland@gmail.com",
        "password": "xwfjdrsrpsxptduk",
        "display_name": "Dr Jeff Sutherland [Gmail]"
    },
    "ff": {
        "email": "drjeffsutherland@frequencyfoundation.com",
        "password": "tmzmytqcjsepsvxz",
        "display_name": "Frequency Foundation"
    },
    "scrum": {
        "email": "jeff.sutherland@scruminc.com",
        "password": "ewxdzesqxloqllwq",
        "display_name": "Jeff Sutherland [Scrum Inc]"
    }
}

def search_emails(account_name, search_terms):
    """Search for emails containing specific terms"""
    if account_name not in ACCOUNTS:
        print(f"Unknown account: {account_name}")
        return
    
    account = ACCOUNTS[account_name]
    
    # Create SSL context that doesn't verify certificates
    context = ssl.create_default_context()
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE
    
    try:
        print(f"🔍 Searching {account['display_name']} for Mission Control invite...")
        
        # Connect to Gmail IMAP
        mail = imaplib.IMAP4_SSL('imap.gmail.com', 993, ssl_context=context)
        mail.login(account['email'], account['password'])
        mail.select('INBOX')
        
        # Search for various terms
        found_any = False
        for term in search_terms:
            print(f"   Searching for: {term}")
            
            # Search in various fields
            for search_field in ['FROM', 'TO', 'SUBJECT', 'BODY']:
                _, search_data = mail.search(None, f'{search_field} "{term}"')
                email_ids = search_data[0].split()
                
                if email_ids and email_ids[0]:
                    print(f"   ✅ Found {len(email_ids)} emails with '{term}' in {search_field}")
                    found_any = True
                    
                    # Show first few matches
                    for email_id in email_ids[-5:]:  # Last 5 matches
                        _, msg_data = mail.fetch(email_id, '(RFC822)')
                        raw_email = msg_data[0][1]
                        msg = email.message_from_bytes(raw_email)
                        
                        # Decode subject
                        subject = decode_header(msg['Subject'])[0][0]
                        if isinstance(subject, bytes):
                            subject = subject.decode(errors='ignore')
                        
                        print(f"      - From: {msg['From'][:50]}")
                        print(f"        Subject: {subject[:60]}")
                        print(f"        Date: {msg['Date'][:30]}")
                        print()
        
        if not found_any:
            print(f"   ❌ No emails found matching search terms")
        
        mail.logout()
        return found_any
        
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False

def main():
    search_terms = [
        'agent.saturday',
        'saturday@scrumai',
        'Mission Control',
        'OpenClaw Mission Control',
        'invite',
        'scrumai.org'
    ]
    
    print("=" * 60)
    print("🔍 Mission Control Invite Search")
    print("=" * 60)
    print()
    
    # Try each account
    for account_name in ['gmail', 'drjeff', 'ff', 'scrum']:
        search_emails(account_name, search_terms)
        print()

if __name__ == "__main__":
    main()