#!/usr/bin/env python3
import urllib.request
import base64
import json

# Read config
config_vars = {}
with open('/workspace/.jira-config', 'r') as f:
    for line in f:
        if 'export' in line and '=' in line:
            parts = line.strip().split('=', 1)
            var_name = parts[0].replace('export ', '')
            var_value = parts[1].strip('"')
            config_vars[var_name] = var_value

# Test connection
jira_url = config_vars['JIRA_URL']
jira_user = config_vars['JIRA_USER']
jira_token = config_vars['JIRA_TOKEN']

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
        print(f"✅ Jira connected!")
        print(f"User: {data.get('displayName', 'Unknown')}")
        print(f"Email: {data.get('emailAddress', 'Unknown')}")
        
    # Now try to get ASF project issues
    print("\n📋 Checking ASF Project...")
    search_url = f"{jira_url}/rest/api/3/search/jql"
    jql = "project = ASF ORDER BY created DESC"
    search_req = urllib.request.Request(f"{search_url}?jql={jql}&maxResults=10")
    search_req.add_header('Authorization', f'Basic {auth_b64}')
    search_req.add_header('Accept', 'application/json')
    
    with urllib.request.urlopen(search_req) as response:
        data = json.loads(response.read().decode())
        print(f"Total ASF issues: {data.get('total', 0)}")
        
        if data.get('issues'):
            print("\nRecent ASF stories:")
            for issue in data['issues'][:5]:
                key = issue['key']
                summary = issue['fields']['summary']
                status = issue['fields']['status']['name']
                print(f"- {key}: {summary} [{status}]")
        
except Exception as e:
    print(f"❌ Jira connection failed: {e}")