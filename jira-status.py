#!/usr/bin/env python3
"""
Mock Jira status checker for ASF project
Returns current sprint and story status
"""
import json
import sys

def get_jira_status():
    """Get mock Jira status for ASF project"""
    
    # Mock data based on current state
    status = {
        "project": "ASF",
        "sprint": {
            "name": "ASF Sprint 2",
            "day": "Day 4 of 7",
            "status": "Active"
        },
        "stories": {
            "in_progress": [
                {"id": "ASF-28", "assignee": "ASF Social Agent", "title": "Community Engagement Strategy"},
                {"id": "ASF-29", "assignee": "ASF Research Agent", "title": "Technical Documentation Update"},
                {"id": "ASF-30", "assignee": "ASF Deploy Agent", "title": "Docker security hardening"}
            ],
            "to_do": [
                {"id": "ASF-27", "assignee": "Unassigned", "title": "Discord Bot Integration"},
                {"id": "ASF-32", "assignee": "Jeff Sutherland", "title": "Post ASF v2.0 announcement on Twitter"},
                {"id": "ASF-33", "assignee": "ASF Sales Agent", "title": "Create ASF Website"}
            ],
            "done": [
                {"id": "ASF-26", "title": "Social media announcement (Moltbook)"},
                {"id": "ASF-25", "title": "Self-healing scanner design"},
                {"id": "ASF-24", "title": "Oracle security fix"}
            ]
        }
    }
    
    return status

def format_brief(status):
    """Format brief status output"""
    sprint = status['sprint']
    stories = status['stories']
    
    output = f"📊 ASF Project Status - {sprint['name']} ({sprint['day']})\n\n"
    
    output += f"In Progress: {len(stories['in_progress'])}\n"
    for story in stories['in_progress']:
        output += f"  • {story['id']}: {story['title']} ({story['assignee']})\n"
    
    output += f"\nTo Do: {len(stories['to_do'])}\n"
    for story in stories['to_do'][:3]:  # Show first 3
        output += f"  • {story['id']}: {story['title']}\n"
    
    output += f"\nDone: {len(stories['done'])} stories completed\n"
    
    return output

if __name__ == "__main__":
    status = get_jira_status()
    
    if "--format" in sys.argv and "brief" in sys.argv:
        print(format_brief(status))
    else:
        print(json.dumps(status, indent=2))