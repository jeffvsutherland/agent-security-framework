#!/usr/bin/env python3
"""
Check ASF story status
"""
import sys
import json
import os
from datetime import datetime

def check_story_status(story_id):
    """Check status of a specific ASF story"""
    
    # Mock data for ASF stories
    stories = {
        "ASF-33": {
            "key": "ASF-33",
            "summary": "Create Agent Security Framework Website",
            "status": "To Do",
            "assignee": "Unassigned",
            "created": "2026-02-18T12:46:17Z",
            "priority": "High",
            "storyPoints": 5,
            "labels": ["website", "sales", "asf"],
            "description": "Create ASF website at scrumai.org/agentsecurityframework"
        },
        "ASF-30": {
            "key": "ASF-30",
            "summary": "Docker security hardening",
            "status": "In Progress",
            "assignee": "ASF Deploy Agent",
            "created": "2026-02-17T10:00:00Z",
            "priority": "High",
            "storyPoints": 3
        },
        "ASF-28": {
            "key": "ASF-28",
            "summary": "Community Engagement Strategy",
            "status": "In Progress",
            "assignee": "ASF Social Agent",
            "created": "2026-02-17T09:00:00Z",
            "priority": "Medium",
            "storyPoints": 5
        },
        "ASF-29": {
            "key": "ASF-29",
            "summary": "Technical Documentation Update",
            "status": "In Progress",
            "assignee": "ASF Research Agent",
            "created": "2026-02-17T09:30:00Z",
            "priority": "Medium",
            "storyPoints": 3
        }
    }
    
    if story_id in stories:
        return stories[story_id]
    else:
        return {"error": f"Story {story_id} not found"}

def format_story_status(story):
    """Format story status for display"""
    if "error" in story:
        return f"❌ {story['error']}"
    
    status_emoji = {
        "To Do": "📋",
        "In Progress": "🔄",
        "Done": "✅"
    }.get(story['status'], "❓")
    
    assignee_status = "✅" if story['assignee'] != "Unassigned" else "⚠️ NOT ASSIGNED"
    
    output = f"{status_emoji} {story['key']}: {story['summary']}\n"
    output += f"Status: {story['status']}\n"
    output += f"Assignee: {story['assignee']} {assignee_status}\n"
    output += f"Priority: {story['priority']} | Points: {story.get('storyPoints', 'N/A')}"
    
    return output

if __name__ == "__main__":
    if len(sys.argv) > 1:
        story_id = sys.argv[1]
        story = check_story_status(story_id)
        print(format_story_status(story))
    else:
        print("Usage: python3 check-asf-status.py <story-id>")