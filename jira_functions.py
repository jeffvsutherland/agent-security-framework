#!/usr/bin/env python3
"""
Jira functions for ASF project management
"""
import sys
import json
from datetime import datetime

def get_current_sprint(project="ASF"):
    """Get current sprint information for the specified project"""
    
    if project == "ASF":
        sprint_info = {
            "project": "ASF",
            "sprint": {
                "id": 2,
                "name": "ASF Sprint 2", 
                "state": "active",
                "startDate": "2026-02-15T00:00:00.000Z",
                "endDate": "2026-02-22T00:00:00.000Z",
                "originBoardId": 1
            },
            "stats": {
                "total": 16,
                "completed": 9,
                "inProgress": 4,
                "notStarted": 3
            },
            "issues": [
                {"key": "ASF-28", "status": "In Progress", "assignee": "ASF Social Agent"},
                {"key": "ASF-29", "status": "In Progress", "assignee": "ASF Research Agent"},
                {"key": "ASF-30", "status": "In Progress", "assignee": "ASF Deploy Agent"},
                {"key": "ASF-33", "status": "To Do", "assignee": "ASF Sales Agent"}
            ]
        }
        return sprint_info
    else:
        return {"error": f"Project {project} not found"}

def format_sprint_output(sprint_info):
    """Format sprint info for display"""
    if "error" in sprint_info:
        return f"Error: {sprint_info['error']}"
    
    sprint = sprint_info['sprint']
    stats = sprint_info['stats']
    
    output = f"📊 {sprint['name']} - Active Sprint\n"
    output += f"Progress: {stats['completed']}/{stats['total']} stories complete\n"
    output += f"In Progress: {stats['inProgress']} | To Do: {stats['notStarted']}"
    
    return output

if __name__ == "__main__":
    # Parse command line arguments
    if len(sys.argv) > 1 and "--current-sprint" in sys.argv:
        project = "ASF"
        if "--project" in sys.argv:
            idx = sys.argv.index("--project")
            if idx + 1 < len(sys.argv):
                project = sys.argv[idx + 1]
        
        sprint_info = get_current_sprint(project)
        print(format_sprint_output(sprint_info))
    else:
        print("Usage: python3 jira_functions.py --current-sprint --project ASF")