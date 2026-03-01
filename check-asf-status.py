#!/usr/bin/env python3
"""
Check ASF story status from Mission Control
"""
import sys
import json
import os
import subprocess
from datetime import datetime

# MC API Configuration
AGENT_TOKEN = "WeWnFbK9IoknRjXFPGsV-xHlgGJkXZNcfgltKCQasFQ"
MC_URL = "http://host.docker.internal:8001"
BOARD = "24394a90-a74e-479c-95e8-e5d24c7b4a40"

def mc_api(endpoint):
    """Call Mission Control API"""
    try:
        result = subprocess.run(
            ["curl", "-s", "-m", "10", "-H", f"Authorization: Bearer {AGENT_TOKEN}", 
             f"{MC_URL}/api/v1/agent/boards/{BOARD}/{endpoint}"],
            capture_output=True, text=True, timeout=15
        )
        return json.loads(result.stdout) if result.stdout else None
    except Exception as e:
        return {"error": str(e)}

def get_all_tasks():
    """Get all tasks from Mission Control"""
    return mc_api("tasks")

def get_task_by_id(task_id):
    """Get a specific task by ID"""
    data = get_all_tasks()
    if data and "items" in data:
        for task in data["items"]:
            if task.get("id") == task_id:
                return task
    return None

def get_tasks_by_status(status):
    """Get tasks filtered by status"""
    data = get_all_tasks()
    if data and "items" in data:
        return [t for t in data["items"] if t.get("status", "").lower() == status.lower()]
    return []

def format_task_status(task, show_id=False):
    """Format task status for display"""
    if not task:
        return "❌ Task not found"
    
    status = task.get("status", "Unknown")
    status_emoji = {
        "inbox": "📋",
        "in_progress": "🔄",
        "done": "✅"
    }.get(status.lower(), "❓")
    
    assignee = task.get("assigned_agent_id")
    assignee_status = "✅" if assignee else "⚠️ NOT ASSIGNED"
    assignee_str = assignee[:20] if assignee else "Unassigned"
    
    title = task.get("title", "No title")[:50]
    task_id = task.get("id", "")[:8]
    
    output = f"{status_emoji} [{task.get('key', task_id)}] {title}\n"
    output += f"Status: {status} | Assignee: {assignee_str} {assignee_status}"
    
    return output

def print_board_summary():
    """Print board summary"""
    data = get_all_tasks()
    if not data or "error" in data:
        print(f"❌ Error fetching board: {data.get('error', 'Unknown error')}")
        return
    
    items = data.get("items", [])
    statuses = {}
    for task in items:
        s = task.get("status", "unknown")
        statuses[s] = statuses.get(s, 0) + 1
    
    print("📊 Mission Control Board Summary:")
    for s, count in sorted(statuses.items()):
        emoji = {"inbox": "📋", "in_progress": "🔄", "done": "✅"}.get(s, "❓")
        print(f"  {emoji} {s}: {count}")
    print(f"\nTotal: {len(items)} tasks")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        
        if arg == "--summary":
            print_board_summary()
        elif arg == "--in-progress":
            tasks = get_tasks_by_status("in_progress")
            for t in tasks:
                print(format_task_status(t))
        elif arg == "--done":
            tasks = get_tasks_by_status("done")
            for t in tasks:
                print(format_task_status(t))
        else:
            # Assume it's a task ID or partial ID
            task = get_task_by_id(arg)
            print(format_task_status(task, show_id=True))
    else:
        print_board_summary()
        print("\nUsage: python3 check-asf-status.py [task-id|--summary|--in-progress|--done]")
