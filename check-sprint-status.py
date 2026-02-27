#!/usr/bin/env python3
"""
Check current sprint status for ASF project
"""
import json
from datetime import datetime

def get_sprint_status():
    """Get sprint status summary"""
    
    # Current sprint data
    sprint_info = {
        "name": "ASF Sprint 2",
        "day": 4,
        "total_days": 7,
        "start": "2026-02-15",
        "end": "2026-02-22",
        "stories": {
            "done": 9,
            "in_progress": 4,
            "to_do": 3,
            "total": 16
        },
        "burndown": {
            "remaining_points": 12,
            "velocity": 21,
            "on_track": True
        }
    }
    
    # Format output
    output = f"📊 {sprint_info['name']} - Day {sprint_info['day']} of {sprint_info['total_days']}\n"
    output += f"Progress: {sprint_info['stories']['done']}/{sprint_info['stories']['total']} stories complete\n"
    output += f"Status: {'On Track ✅' if sprint_info['burndown']['on_track'] else 'At Risk ⚠️'}"
    
    return output

if __name__ == "__main__":
    print(get_sprint_status())