#!/usr/bin/env python3
"""
Jira API v3 access for ASF project
"""
import os
import json
import requests
from requests.auth import HTTPBasicAuth

# Configuration
JIRA_URL = "https://frequencyfoundation.atlassian.net"
EMAIL = "jeff.sutherland@gmail.com"
API_TOKEN = os.environ.get('JIRA_API_TOKEN')

def get_auth():
    """Get authentication for Jira API"""
    if not API_TOKEN:
        print("Error: JIRA_API_TOKEN environment variable not set")
        exit(1)
    return HTTPBasicAuth(EMAIL, API_TOKEN)

def get_project_issues(project_key="ASF", max_results=50):
    """Get all issues for a project"""
    url = f"{JIRA_URL}/rest/api/3/search/jql"
    
    jql = f"project = {project_key} ORDER BY key ASC"
    
    params = {
        "jql": jql,
        "maxResults": max_results,
        "fields": "summary,status,customfield_10016,assignee,description,issuetype"  # customfield_10016 is usually story points
    }
    
    response = requests.get(url, auth=get_auth(), params=params)
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code}")
        print(response.text)
        return None

def list_issues_without_story_points(project_key="ASF"):
    """List all issues that don't have story points"""
    issues = get_project_issues(project_key)
    
    if not issues:
        return
    
    print(f"\n📋 {project_key} Issues Without Story Points:\n")
    print(f"{'Key':<10} {'Type':<10} {'Status':<15} {'Summary':<50}")
    print("-" * 90)
    
    no_points_count = 0
    
    for issue in issues.get('issues', []):
        key = issue['key']
        fields = issue['fields']
        story_points = fields.get('customfield_10016')  # Story points field
        
        if story_points is None:
            no_points_count += 1
            issue_type = fields['issuetype']['name']
            status = fields['status']['name']
            summary = fields['summary'][:50]
            
            print(f"{key:<10} {issue_type:<10} {status:<15} {summary:<50}")
    
    print(f"\n Total issues without story points: {no_points_count}")

def update_story_points(issue_key, points):
    """Update story points for a specific issue"""
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}"
    
    data = {
        "fields": {
            "customfield_10016": float(points)  # Story points field
        }
    }
    
    response = requests.put(url, auth=get_auth(), json=data)
    
    if response.status_code == 204:
        print(f"✅ Updated {issue_key} with {points} story points")
        return True
    else:
        print(f"❌ Failed to update {issue_key}: {response.status_code}")
        print(response.text)
        return False

def get_all_fields():
    """Get all available fields to find the correct story points field"""
    url = f"{JIRA_URL}/rest/api/3/field"
    response = requests.get(url, auth=get_auth())
    
    if response.status_code == 200:
        fields = response.json()
        for field in fields:
            if 'story' in field['name'].lower() or 'point' in field['name'].lower():
                print(f"Field: {field['name']} - ID: {field['id']}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python jira-api-access.py list                    # List issues without story points")
        print("  python jira-api-access.py fields                  # Show all fields")
        print("  python jira-api-access.py update <key> <points>  # Update story points")
        print("\nExample:")
        print("  python jira-api-access.py update ASF-15 8")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "list":
        list_issues_without_story_points()
    elif command == "fields":
        get_all_fields()
    elif command == "update" and len(sys.argv) == 4:
        issue_key = sys.argv[2]
        points = sys.argv[3]
        update_story_points(issue_key, points)
    else:
        print("Invalid command or arguments")