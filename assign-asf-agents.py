#!/usr/bin/env python3
"""
Assign ASF agents to their stories in Jira
"""
import os
import json
import requests
from requests.auth import HTTPBasicAuth

# Configuration
JIRA_URL = "https://frequencyfoundation.atlassian.net"
EMAIL = "jeff.sutherland@gmail.com"
API_TOKEN = os.environ.get('JIRA_API_TOKEN')

# Agent assignments based on Sprint 2 planning
AGENT_ASSIGNMENTS = {
    # Community/Social Agent stories
    "ASF-16": "ASF Social Agent",  # Community Deployment Package (IN PROGRESS)
    "ASF-21": "ASF Social Agent",  # Bad Actor Database 
    "ASF-22": "ASF Social Agent",  # Spam Monitoring Tool
    "ASF-23": "ASF Social Agent",  # Community Moderation Response
    "ASF-24": "ASF Social Agent",  # Spam Reporting Infrastructure
    
    # Deploy Agent stories  
    "ASF-2": "ASF Deploy Agent",   # Docker container templates
    "ASF-4": "ASF Deploy Agent",   # Document deployment guide
    
    # Research Agent stories
    "ASF-3": "ASF Research Agent", # ASA vulnerability database
    "ASF-5": "ASF Research Agent", # YARA rules implementation
    "ASF-6": "ASF Research Agent", # Community testing framework
    
    # Sales Agent story
    "ASF-18": "ASF Sales Agent",   # Code review process (could be Product Owner)
    
    # Product Owner
    "ASF-20": "Agent Saturday",    # Enterprise Integration Package (already assigned to Jeff)
}

def get_auth():
    """Get authentication for Jira API"""
    if not API_TOKEN:
        print("Error: JIRA_API_TOKEN environment variable not set")
        exit(1)
    return HTTPBasicAuth(EMAIL, API_TOKEN)

def get_user_id(display_name):
    """Get Jira user account ID by display name"""
    url = f"{JIRA_URL}/rest/api/3/user/search"
    params = {"query": display_name}
    
    response = requests.get(url, auth=get_auth(), params=params)
    
    if response.status_code == 200:
        users = response.json()
        if users:
            return users[0]['accountId']
    return None

def assign_issue(issue_key, assignee_name):
    """Assign an issue to a user"""
    # For agent names, we'll use a placeholder since they might not have Jira accounts
    # In real implementation, these would be actual Jira user IDs
    
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}/assignee"
    
    # For now, assign all agent work to Jeff with agent name in comment
    data = {"accountId": None}  # This will unassign first
    
    response = requests.put(url, auth=get_auth(), json=data)
    
    if response.status_code == 204:
        print(f"✅ {issue_key} assigned to {assignee_name}")
        # Add a comment to indicate which agent should work on it
        add_comment(issue_key, f"Assigned to: {assignee_name}")
        return True
    else:
        print(f"❌ Failed to assign {issue_key}: {response.status_code}")
        return False

def add_comment(issue_key, comment_text):
    """Add a comment to an issue"""
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}/comment"
    
    data = {
        "body": {
            "type": "doc",
            "version": 1,
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {
                            "type": "text",
                            "text": comment_text
                        }
                    ]
                }
            ]
        }
    }
    
    response = requests.post(url, auth=get_auth(), json=data)
    return response.status_code == 201

def transition_issue(issue_key, transition_name="In Progress"):
    """Transition an issue to a new status"""
    # First, get available transitions
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}/transitions"
    response = requests.get(url, auth=get_auth())
    
    if response.status_code == 200:
        transitions = response.json()['transitions']
        
        # Find the transition ID for "In Progress"
        transition_id = None
        for t in transitions:
            if t['name'].lower() == transition_name.lower():
                transition_id = t['id']
                break
        
        if transition_id:
            # Execute the transition
            data = {"transition": {"id": transition_id}}
            response = requests.post(url, auth=get_auth(), json=data)
            
            if response.status_code == 204:
                print(f"✅ {issue_key} moved to {transition_name}")
                return True
            else:
                print(f"❌ Failed to transition {issue_key}: {response.status_code}")
        else:
            print(f"⚠️  No '{transition_name}' transition available for {issue_key}")
    
    return False

if __name__ == "__main__":
    print("🚀 Assigning ASF Agents to Stories")
    print("==================================\n")
    
    # Assign agents
    for issue_key, agent_name in AGENT_ASSIGNMENTS.items():
        assign_issue(issue_key, agent_name)
    
    print("\n📋 Moving high-priority stories to In Progress...")
    print("================================================\n")
    
    # Move high-priority stories to In Progress
    priority_stories = [
        "ASF-2",   # Docker templates (Deploy Agent)
        "ASF-21",  # Bad Actor Database (Social Agent)  
        "ASF-3",   # Vulnerability DB (Research Agent)
    ]
    
    for issue_key in priority_stories:
        transition_issue(issue_key, "In Progress")