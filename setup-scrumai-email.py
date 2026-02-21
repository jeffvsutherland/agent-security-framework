#!/usr/bin/env python3
"""
Test email setup for agent.saturday@scrumai.org
Google Workspace accounts use Gmail's servers
"""
import imaplib
import ssl

# Create SSL context that doesn't verify certificates (for AVG proxy)
context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

email = "agent.saturday@scrumai.org"
password = "asfAgentSaturday5335!!"

print(f"Testing email setup for: {email}")
print("=" * 50)

# Try Gmail IMAP settings (Google Workspace uses these)
servers = [
    ("imap.gmail.com", 993),
    ("imap.googlemail.com", 993)
]

for server, port in servers:
    print(f"\nTrying {server}:{port}...")
    try:
        # Connect to IMAP server
        mail = imaplib.IMAP4_SSL(server, port, ssl_context=context)
        mail.login(email, password)
        
        # List folders
        print("✅ Login successful!")
        status, folders = mail.list()
        print("\nAvailable folders:")
        for folder in folders[:5]:  # Show first 5
            print(f"  - {folder.decode()}")
        
        # Check INBOX
        mail.select('INBOX')
        status, data = mail.search(None, 'ALL')
        num_messages = len(data[0].split())
        print(f"\nTotal messages in INBOX: {num_messages}")
        
        mail.logout()
        break
        
    except Exception as e:
        print(f"❌ Error: {e}")
        if "AUTHENTICATIONFAILED" in str(e):
            print("\nPossible issues:")
            print("1. Account may need 'Less secure app access' enabled")
            print("2. May need an App Password instead of regular password")
            print("3. Account might not be fully activated yet")
            print("4. 2FA might be enabled")

print("\n" + "=" * 50)
print("Setup test complete.")