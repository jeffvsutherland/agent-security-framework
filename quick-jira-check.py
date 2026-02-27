#!/usr/bin/env python3
import requests
import json
import base64
import os

# Read config
config_path = os.path.expanduser("~/.jira-config")
config = {}
with open(config_path, 'r') as f:
    for line in f:
        if '=' in line and not line.startswith('#'):
            key, value = line.strip().split('=', 1)
            config[key] = value.strip('"')

# Create auth
auth_string = f"{config['JIRA_USER']}:{config['JIRA_TOKEN']}"
auth_bytes = auth_string.encode('ascii')
auth_b64 = base64.b64encode(auth_bytes).decode('ascii')

headers = {
    'Authorization': f'Basic {auth_b64}',
    'Accept': 'application/json'
}

# Test connection
print("Testing Jira connection...")
url = f"{config['JIRA_URL']}/rest/api/3/myself"
response = requests.get(url, headers=headers)

if response.status_code == 200:
    user = response.json()
    print(f"✓ Connected as: {user.get('displayName', 'Unknown')}")
    
    # Get ASF project issues
    print("\n📋 ASF Project Status:")
    jql = "project = ASF ORDER BY created DESC"
    search_url = f"{config['JIRA_URL']}/rest/api/3/search"
    params = {'jql': jql, 'maxResults': 20}
    
    search_response = requests.get(search_url, headers=headers, params=params)
    if search_response.status_code == 200:
        data = search_response.json()
        print(f"Total ASF issues: {data.get('total', 0)}")
        
        if data.get('issues'):
            print("\nRecent issues:")
            for issue in data['issues'][:10]:
                key = issue['key']
                summary = issue['fields']['summary']
                status = issue['fields']['status']['name']
                print(f"- {key}: {summary} ({status})")
    else:
        print(f"Search failed: {search_response.status_code}")
        
    # Try FF project too
    print("\n📋 FF Project Status:")
    jql = "project = FF ORDER BY created DESC"
    params = {'jql': jql, 'maxResults': 20}
    
    search_response = requests.get(search_url, headers=headers, params=params)
    if search_response.status_code == 200:
        data = search_response.json()
        print(f"Total FF issues: {data.get('total', 0)}")
        
        if data.get('issues'):
            print("\nRecent issues:")
            for issue in data['issues'][:10]:
                key = issue['key']
                summary = issue['fields']['summary']
                status = issue['fields']['status']['name']
                assignee = issue['fields'].get('assignee', {})
                assignee_name = assignee.get('displayName', 'Unassigned') if assignee else 'Unassigned'
                print(f"- {key}: {summary} ({status}) - {assignee_name}")
else:
    print(f"✗ Authentication failed: {response.status_code}")
    print(f"Response: {response.text[:200]}")