#!/usr/bin/env python3
"""
Get Jira sprint information for ASF project
"""
import json
from datetime import datetime

def get_sprint_info():
    """Get current sprint information"""
    
    # Mock sprint data based on current state
    sprint_data = {
        "project": "ASF",
        "sprint": {
            "id": "ASF Sprint 2",
            "name": "ASF Sprint 2",
            "state": "active",
            "startDate": "2026-02-15",
            "endDate": "2026-02-22",
            "day": 4,
            "totalDays": 7
        },
        "stories": {
            "todo": 3,
            "inProgress": 4,
            "done": 9,
            "total": 16
        },
        "velocity": {
            "current": 0,
            "previous": 21
        },
        "agents": {
            "deploy": {"story": "ASF-30", "status": "In Progress"},
            "sales": {"story": "ASF-33", "status": "To Do"},
            "social": {"story": "ASF-28", "status": "In Progress"},
            "research": {"story": "ASF-29", "status": "In Progress"}
        }
    }
    
    return sprint_data

def format_sprint_summary():
    """Format sprint summary for heartbeat"""
    data = get_sprint_info()
    sprint = data['sprint']
    stories = data['stories']
    
    output = f"📊 Sprint Status: {sprint['name']} (Day {sprint['day']} of {sprint['totalDays']})\n"
    output += f"Stories: {stories['done']} Done | {stories['inProgress']} In Progress | {stories['todo']} To Do\n"
    output += f"Previous Velocity: {data['velocity']['previous']} points"
    
    return output

if __name__ == "__main__":
    print(format_sprint_summary())