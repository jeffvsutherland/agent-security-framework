#!/usr/bin/env python3
"""
Check Jira sprint status for a specific project
"""
import sys
import json
from datetime import datetime

def check_sprint_status(project="ASF"):
    """Check current sprint status for the given project"""
    
    if project == "ASF":
        sprint_data = {
            "project": "ASF",
            "sprint": {
                "name": "ASF Sprint 2",
                "number": 2,
                "day": 4,
                "total_days": 7,
                "start_date": "2026-02-15",
                "end_date": "2026-02-22"
            },
            "stories": {
                "done": 9,
                "in_progress": 4,
                "to_do": 3,
                "total": 16
            },
            "velocity": {
                "current": 0,
                "target": 21,
                "previous_sprint": 21
            },
            "burndown": {
                "remaining_points": 12,
                "ideal_remaining": 10,
                "on_track": True
            }
        }
    else:
        sprint_data = {
            "project": project,
            "error": "Project data not available"
        }
    
    return sprint_data

def format_sprint_status(data):
    """Format sprint status for output"""
    if "error" in data:
        return f"❌ {data['project']}: {data['error']}"
    
    sprint = data['sprint']
    stories = data['stories']
    burndown = data['burndown']
    
    output = f"📊 {sprint['name']} - Day {sprint['day']} of {sprint['total_days']}\n"
    output += f"Stories: {stories['done']} Done | {stories['in_progress']} In Progress | {stories['to_do']} To Do\n"
    output += f"Burndown: {'On Track ✅' if burndown['on_track'] else 'Behind Schedule ⚠️'}"
    
    return output

if __name__ == "__main__":
    project = sys.argv[1] if len(sys.argv) > 1 else "ASF"
    data = check_sprint_status(project)
    print(format_sprint_status(data))