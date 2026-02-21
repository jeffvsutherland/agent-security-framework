#!/usr/bin/env python3
"""
Moltbook authentication and email setup using existing API key
"""
import requests
import json
import os

# Load credentials
creds_path = os.path.expanduser("~/.config/moltbook/credentials.json")
with open(creds_path) as f:
    creds = json.load(f)

API_KEY = creds["api_key"]
API_URL = creds["api_url"].rstrip('/')
EMAIL = "agent.saturday@scrumai.org"

def setup_owner_email():
    """
    Set up owner email using authenticated API call
    """
    url = f"{API_URL}/agents/me/setup-owner-email"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "email": EMAIL
    }
    
    print(f"🔧 Setting up email for Moltbook agent")
    print(f"Email: {EMAIL}")
    print(f"API: {url}")
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        
        print(f"\nStatus: {response.status_code}")
        
        if response.status_code in [200, 201]:
            print("✅ Success! Email configured.")
            data = response.json()
            print(json.dumps(data, indent=2))
            return True
        else:
            print(f"❌ Failed with status {response.status_code}")
            print(f"Response: {response.text}")
            
            # Parse error for more info
            try:
                error_data = response.json()
                if "suggestion" in error_data:
                    print(f"\n💡 Suggestion: {error_data['suggestion']}")
                if "hint" in error_data:
                    print(f"💡 Hint: {error_data['hint']}")
            except:
                pass
                
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def get_agent_info():
    """
    Get current agent information
    """
    url = f"{API_URL}/agents/me"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}"
    }
    
    print("\n📋 Getting current agent info...")
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            print("✅ Agent info retrieved:")
            data = response.json()
            print(json.dumps(data, indent=2))
            return data
        else:
            print(f"❌ Failed: {response.status_code}")
            print(response.text)
            return None
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def update_password():
    """
    Update Moltbook password if needed
    """
    url = f"{API_URL}/agents/me/update-password"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Use same password as email for consistency
    new_password = "asfAgentSaturday5335!!"
    
    payload = {
        "password": new_password
    }
    
    print(f"\n🔑 Updating password...")
    
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        
        if response.status_code in [200, 201]:
            print("✅ Password updated successfully!")
            return True
        else:
            print(f"Status: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("=" * 50)
    print("🤖 Moltbook Authentication Setup")
    print(f"Using API key: {API_KEY[:20]}...")
    print("=" * 50)
    
    # First get current agent info
    agent_info = get_agent_info()
    
    # Then set up email
    if setup_owner_email():
        print("\n✅ Email setup complete!")
        
        # Optionally update password
        print("\nWould update password to match email password.")
        # Uncomment to actually update:
        # update_password()
    else:
        print("\n⚠️ Email setup failed. Check the error messages above.")

if __name__ == "__main__":
    main()