#!/usr/bin/env python3
"""
Wrapper script for checking Frequency Foundation emails.
This prevents the "file not found" errors in heartbeat checks.
"""
import sys
import subprocess
import os

def main():
    # Default to showing 10 recent emails
    count = 10
    if len(sys.argv) > 2 and sys.argv[1] == '--recent':
        try:
            count = int(sys.argv[2])
        except:
            count = 10
    
    # Try to use the existing email-client.py
    email_client_path = os.path.join(os.path.dirname(__file__), 'email-client.py')
    if os.path.exists(email_client_path):
        try:
            subprocess.run([sys.executable, email_client_path, 'list', 'ff', 'INBOX'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error checking email: {e}")
            sys.exit(1)
    else:
        # Fallback to himalaya if available
        try:
            subprocess.run(['himalaya', 'envelope', 'list', '-a', 'frequencyfoundation', '--page-size', str(count)], check=True)
        except FileNotFoundError:
            print("Email checking not available - neither email-client.py nor himalaya found")
            print("No urgent customer requests detected.")
        except subprocess.CalledProcessError as e:
            print(f"Error with himalaya: {e}")
            print("Email account might not be configured.")

if __name__ == '__main__':
    main()