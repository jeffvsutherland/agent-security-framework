#!/usr/bin/env python3
"""
Comprehensive Google Workspace email authentication tester
Tries multiple methods to connect to agent.saturday@scrumai.org
"""
import imaplib
import ssl
import smtplib
from datetime import datetime

# Account details
EMAIL = "agent.saturday@scrumai.org"
PASSWORD = "asfAgentSaturday5335!!"

# Create SSL context that bypasses cert verification (AVG proxy)
context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

print(f"🔍 Testing authentication for: {EMAIL}")
print(f"Time: {datetime.now()}")
print("=" * 70)

# Test 1: IMAP with different settings
print("\n1️⃣ Testing IMAP connections...")
imap_configs = [
    # Standard Gmail
    ("imap.gmail.com", 993, "SSL"),
    # Alternative Gmail
    ("imap.googlemail.com", 993, "SSL"),
    # With STARTTLS
    ("imap.gmail.com", 143, "STARTTLS"),
]

for host, port, method in imap_configs:
    print(f"\n   Trying {host}:{port} ({method})...")
    try:
        if method == "SSL":
            mail = imaplib.IMAP4_SSL(host, port, ssl_context=context)
        else:
            mail = imaplib.IMAP4(host, port)
            mail.starttls(ssl_context=context)
        
        # Try login
        mail.login(EMAIL, PASSWORD)
        print(f"   ✅ SUCCESS! Connected via {method}")
        
        # Get some info
        status, data = mail.capability()
        print(f"   Capabilities: {data[0].decode()[:50]}...")
        
        mail.logout()
        break
        
    except Exception as e:
        error_msg = str(e)
        print(f"   ❌ Failed: {error_msg}")
        
        # Analyze error
        if "AUTHENTICATIONFAILED" in error_msg:
            print("      → Authentication issue - likely need app password")
        elif "Connection refused" in error_msg:
            print("      → Port blocked or service down")
        elif "timeout" in error_msg:
            print("      → Network timeout - firewall issue?")

# Test 2: SMTP (for sending)
print("\n\n2️⃣ Testing SMTP connections...")
smtp_configs = [
    ("smtp.gmail.com", 587, "STARTTLS"),
    ("smtp.gmail.com", 465, "SSL"),
    ("smtp.googlemail.com", 587, "STARTTLS"),
]

for host, port, method in smtp_configs:
    print(f"\n   Trying {host}:{port} ({method})...")
    try:
        if method == "SSL":
            server = smtplib.SMTP_SSL(host, port, context=context)
        else:
            server = smtplib.SMTP(host, port)
            server.starttls(context=context)
        
        server.login(EMAIL, PASSWORD)
        print(f"   ✅ SUCCESS! Can send mail via {method}")
        server.quit()
        break
        
    except Exception as e:
        print(f"   ❌ Failed: {str(e)[:100]}")

# Test 3: Check if it's expecting different username format
print("\n\n3️⃣ Testing alternative username formats...")
alt_usernames = [
    EMAIL,  # Full email
    "agent.saturday",  # Without domain
    "agent-saturday",  # With dash
    "agentsaturday",  # No punctuation
]

for username in alt_usernames:
    print(f"\n   Trying username: {username}")
    try:
        mail = imaplib.IMAP4_SSL("imap.gmail.com", 993, ssl_context=context)
        mail.login(username, PASSWORD)
        print(f"   ✅ SUCCESS with username: {username}")
        mail.logout()
        break
    except:
        print(f"   ❌ Failed")

# Provide guidance
print("\n\n📋 AUTHENTICATION DIAGNOSIS:")
print("=" * 70)
print("\nIf all methods failed with AUTHENTICATIONFAILED:")
print("1. Account needs an App Password (most likely)")
print("   → Go to myaccount.google.com/apppasswords")
print("   → Generate one for 'Mail'")
print("\n2. Account might have 2FA enabled")
print("   → App passwords are required with 2FA")
print("\n3. Less secure app access might be disabled")
print("   → Admin needs to enable in Google Workspace admin")
print("\n4. Account might need initial web login")
print("   → Try logging in at mail.google.com first")
print("\nNext steps:")
print("- Ask for an app-specific password")
print("- Or ask admin to check security settings")
print("=" * 70)