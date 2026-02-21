#!/usr/bin/env python3
"""
Moltbook authentication with proxy/SSL bypass
Similar to how we fixed email access
"""
import requests
import json
import os
import ssl
import urllib3

# Disable SSL warnings (AVG proxy issue)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Load credentials
creds_path = os.path.expanduser("~/.config/moltbook/credentials.json")
with open(creds_path) as f:
    creds = json.load(f)

API_KEY = creds["api_key"]
API_URL = creds["api_url"].rstrip('/')
EMAIL = "agent.saturday@scrumai.org"

def make_request(method, endpoint, payload=None):
    """
    Make request with SSL verification disabled (AVG proxy workaround)
    """
    url = f"{API_URL}{endpoint}"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "User-Agent": "MoltbookAgent/1.0"
    }
    
    try:
        if method == "GET":
            response = requests.get(
                url, 
                headers=headers, 
                timeout=30,
                verify=False  # Bypass SSL cert verification
            )
        elif method == "POST":
            response = requests.post(
                url, 
                json=payload, 
                headers=headers, 
                timeout=30,
                verify=False  # Bypass SSL cert verification
            )
        
        return response
        
    except Exception as e:
        print(f"❌ Request error: {e}")
        return None

def test_connection():
    """
    Test basic API connectivity
    """
    print("🔍 Testing API connection...")
    
    # Try a simple endpoint
    response = make_request("GET", "/health")
    
    if response:
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            print("✅ API is reachable!")
            return True
        else:
            print(f"Response: {response.text[:200]}")
    else:
        print("❌ Cannot reach API")
    
    return False

def setup_owner_email():
    """
    Set up owner email with proxy workaround
    """
    print(f"\n🔧 Setting up email: {EMAIL}")
    
    payload = {"email": EMAIL}
    response = make_request("POST", "/agents/me/setup-owner-email", payload)
    
    if response:
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            print("✅ Email configured successfully!")
            try:
                data = response.json()
                print(json.dumps(data, indent=2))
            except:
                print(response.text)
            return True
        else:
            print(f"❌ Failed: {response.text[:500]}")
            
            # Check if we need to login first
            if "login" in response.text.lower() or "auth" in response.text.lower():
                print("\n💡 Hint: May need to login via web interface first")
                print("Visit: https://www.moltbook.com/login")
                print(f"Email: {EMAIL}")
    
    return False

def get_agent_info():
    """
    Get current agent information
    """
    print("\n📋 Getting agent info...")
    
    response = make_request("GET", "/agents/me")
    
    if response and response.status_code == 200:
        print("✅ Agent info retrieved:")
        try:
            data = response.json()
            print(json.dumps(data, indent=2))
            
            # Check if email is already set
            if "email" in data:
                print(f"\nCurrent email: {data['email']}")
            if "owner_email" in data:
                print(f"Owner email: {data['owner_email']}")
                
        except:
            print(response.text)
        return True
    
    return False

def main():
    print("=" * 60)
    print("🤖 Moltbook Setup (with SSL bypass for AVG proxy)")
    print(f"API Key: {API_KEY[:20]}...")
    print("=" * 60)
    
    # Test connection first
    if not test_connection():
        print("\n⚠️ Cannot connect to Moltbook API")
        print("\nTroubleshooting:")
        print("1. Check if moltbook.com is accessible")
        print("2. Try via web browser: https://www.moltbook.com")
        print("3. May need VPN or different network")
        return
    
    # Get current info
    get_agent_info()
    
    # Set up email
    if setup_owner_email():
        print("\n✅ Setup complete!")
    else:
        print("\n📌 Next steps:")
        print("1. Login via web: https://www.moltbook.com/login")
        print(f"2. Use email: {EMAIL}")
        print("3. Create account if needed")
        print("4. Then run this script again")

if __name__ == "__main__":
    main()