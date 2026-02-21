#!/usr/bin/env python3
"""
Moltbook account setup for agent.saturday@scrumai.org
Attempts login or creates new account
"""
import requests
import json

# Moltbook API configuration
MOLTBOOK_API = "https://moltbook.com/api/v1"  # Adjust if different
EMAIL = "agent.saturday@scrumai.org"
PASSWORD = "asfAgentSaturday5335!!"  # Same as email password initially

def setup_owner_email():
    """
    Use the API endpoint mentioned to set up owner email
    POST /api/v1/agents/me/setup-owner-email
    """
    url = f"{MOLTBOOK_API}/agents/me/setup-owner-email"
    
    payload = {
        "email": EMAIL
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    print(f"🔧 Setting up Moltbook for: {EMAIL}")
    print(f"API Endpoint: {url}")
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        
        if response.status_code == 200:
            print("✅ Success! Email configured.")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ Failed with status {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection error: {e}")
        return False

def try_login():
    """
    Attempt to login with existing credentials
    """
    login_url = f"{MOLTBOOK_API}/auth/login"
    
    payload = {
        "email": EMAIL,
        "password": PASSWORD
    }
    
    print(f"\n🔑 Attempting login...")
    
    try:
        response = requests.post(login_url, json=payload, timeout=10)
        
        if response.status_code == 200:
            print("✅ Login successful!")
            data = response.json()
            if 'token' in data:
                print(f"Auth token: {data['token'][:20]}...")
            return True
        else:
            print(f"❌ Login failed: {response.status_code}")
            print("Will try to create new account...")
            return False
            
    except Exception as e:
        print(f"❌ Login error: {e}")
        return False

def create_account():
    """
    Create new Moltbook account if login fails
    """
    register_url = f"{MOLTBOOK_API}/auth/register"
    
    payload = {
        "email": EMAIL,
        "password": PASSWORD,
        "name": "Agent Saturday (Raven)",
        "role": "product_owner"
    }
    
    print(f"\n📝 Creating new account...")
    
    try:
        response = requests.post(register_url, json=payload, timeout=10)
        
        if response.status_code in [200, 201]:
            print("✅ Account created successfully!")
            return True
        else:
            print(f"❌ Registration failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Registration error: {e}")
        return False

def main():
    print("=" * 50)
    print("🤖 Moltbook Setup for Agent Saturday")
    print("=" * 50)
    
    # First try the setup-owner-email endpoint
    if setup_owner_email():
        print("\n✅ Email setup complete!")
        return
    
    # Then try login
    if try_login():
        print("\n✅ Already have an account!")
        return
    
    # If login fails, create new account
    if create_account():
        print("\n✅ New account created!")
        return
    
    print("\n❌ All methods failed. Manual intervention needed.")
    print("\nPossible issues:")
    print("1. Wrong API endpoint (need correct Moltbook URL)")
    print("2. Service requires manual web registration")
    print("3. Different authentication method needed")

if __name__ == "__main__":
    main()