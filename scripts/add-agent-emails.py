#!/usr/bin/env python3
"""
Add agent email accounts to check-email.py
Run this after generating app passwords for all agent accounts
"""

# Template for new agent accounts
# Replace the PASSWORD_HERE values with actual 16-character app passwords

AGENT_ACCOUNTS = {
    "agent-saturday": {
        "email": "agent.saturday@scrumai.org",
        "password": "APP_PASSWORD_HERE",  # Generate at https://myaccount.google.com/apppasswords
        "display_name": "Agent Saturday (Raven)"
    },
    "asf-research": {
        "email": "asf.research@scrumai.org",
        "password": "APP_PASSWORD_HERE",  # Generate at https://myaccount.google.com/apppasswords
        "display_name": "ASF Research Agent"
    },
    "asf-social": {
        "email": "asf.social@scrumai.org",
        "password": "APP_PASSWORD_HERE",  # Generate at https://myaccount.google.com/apppasswords
        "display_name": "ASF Social Agent"
    },
    "asf-sales": {
        "email": "asf.sales@scrumai.org",
        "password": "APP_PASSWORD_HERE",  # Generate at https://myaccount.google.com/apppasswords
        "display_name": "ASF Sales Agent"
    },
    "asf-deploy": {
        "email": "asf.deploy@scrumai.org",
        "password": "APP_PASSWORD_HERE",  # Generate at https://myaccount.google.com/apppasswords
        "display_name": "ASF Deploy Agent"
    },
    "jeff-scrumai": {
        "email": "jeff.sutherland@scrumai.org",
        "password": "APP_PASSWORD_HERE",  # Generate at https://myaccount.google.com/apppasswords
        "display_name": "Jeff Sutherland (ScrumAI)"
    }
}

print("To add these accounts to check-email.py:")
print("\n1. Generate app passwords for each email account")
print("2. Replace 'APP_PASSWORD_HERE' with actual passwords")
print("3. Add this dictionary to the ACCOUNTS section in check-email.py\n")

for key, account in AGENT_ACCOUNTS.items():
    print(f'    "{key}": {{')
    print(f'        "email": "{account["email"]}",')
    print(f'        "password": "{account["password"]}",')
    print(f'        "display_name": "{account["display_name"]}"')
    print('    },')
