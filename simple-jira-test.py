#!/usr/bin/env python3
import urllib.request
import urllib.parse
import base64
import json

# Direct credentials
jira_url = "https://frequencyfoundation.atlassian.net"
jira_user = "drjeffsutherland@gmail.com"  
jira_token = "ATATT3xFfGF0khSabkTKRWmFCJ2ft6E-Mj_DpPxJEY-J3iccP6zn2ofP0yvApuT5C9L29xAHjEVOAKDjKXOBUA2U3ugzHoIK5b-FpLISFRwTiC4iRvqpQ6NHdv8cUmP-k0xV85WDoF8UBx5Z-X8tLiCL4pP-72iIOGrIlYCZ9iFigyuu4U-wN08=8086D014"

# Create auth header
auth_string = f"{jira_user}:{jira_token}"
auth_bytes = auth_string.encode('ascii')
auth_b64 = base64.b64encode(auth_bytes).decode('ascii')

# Test with myself endpoint
url = f"{jira_url}/rest/api/3/myself"
req = urllib.request.Request(url)
req.add_header('Authorization', f'Basic {auth_b64}')
req.add_header('Accept', 'application/json')

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        print(f"✅ Connected as: {data.get('displayName', 'Unknown')}")
        print(f"Email: {data.get('emailAddress', 'Unknown')}")
except Exception as e:
    print(f"❌ Failed: {e}")
    
# Try to get projects
print("\n📋 Checking projects...")
projects_url = f"{jira_url}/rest/api/3/project"
req = urllib.request.Request(projects_url)
req.add_header('Authorization', f'Basic {auth_b64}')
req.add_header('Accept', 'application/json')

try:
    with urllib.request.urlopen(req) as response:
        projects = json.loads(response.read().decode())
        print(f"Found {len(projects)} projects:")
        for p in projects:
            print(f"  - {p['key']}: {p['name']}")
except Exception as e:
    print(f"❌ Projects failed: {e}")