#!/usr/bin/env python3
"""
Agent Self-Assignment Tool for Mission Control Board

This script allows any agent to self-assign unassigned tasks from the board.
Each agent authenticates with their own agent token.

Usage:
  # List unassigned tasks
  python3 agent-self-assign.py --token <AGENT_TOKEN> --list

  # Self-assign a specific task
  python3 agent-self-assign.py --token <AGENT_TOKEN> --assign <TASK_ID>

  # Self-assign by task title keyword
  python3 agent-self-assign.py --token <AGENT_TOKEN> --assign-by-title "website"

  # Show my assigned tasks
  python3 agent-self-assign.py --token <AGENT_TOKEN> --my-tasks

Environment:
  MC_API_URL  - Mission Control API URL (default: http://localhost:8001)
  MC_AGENT_TOKEN - Agent token (alternative to --token flag)
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error

MC_API = os.environ.get("MC_API_URL", "http://localhost:8001")
BOARD_ID = "24394a90-a74e-479c-95e8-e5d24c7b4a40"


def api_call(method, path, token, data=None):
    """Make an authenticated API call to Mission Control."""
    body = json.dumps(data).encode() if data else None
    headers = {
        "X-Agent-Token": token,
        "Content-Type": "application/json",
    }
    req = urllib.request.Request(
        f"{MC_API}{path}",
        data=body,
        headers=headers,
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def get_my_identity(token):
    """Get the authenticated agent's identity."""
    status, resp = api_call("GET", "/api/v1/agent/healthz", token)
    if status != 200:
        print(f"❌ Authentication failed: {resp}")
        sys.exit(1)
    return resp


def list_unassigned_tasks(token):
    """List all unassigned inbox tasks."""
    status, resp = api_call(
        "GET",
        f"/api/v1/agent/boards/{BOARD_ID}/tasks?unassigned=true&status_filter=inbox",
        token,
    )
    if status != 200:
        print(f"❌ Failed to list tasks: {resp}")
        return []
    tasks = resp.get("items", resp) if isinstance(resp, dict) else resp
    return tasks


def list_my_tasks(token, agent_id):
    """List tasks assigned to me."""
    status, resp = api_call(
        "GET",
        f"/api/v1/agent/boards/{BOARD_ID}/tasks?assigned_agent_id={agent_id}",
        token,
    )
    if status != 200:
        print(f"❌ Failed to list tasks: {resp}")
        return []
    tasks = resp.get("items", resp) if isinstance(resp, dict) else resp
    return tasks


def self_assign_task(token, task_id, agent_id):
    """Assign a task to the authenticated agent."""
    status, resp = api_call(
        "PATCH",
        f"/api/v1/agent/boards/{BOARD_ID}/tasks/{task_id}",
        token,
        {"assigned_agent_id": agent_id, "status": "in_progress"},
    )
    if status == 200:
        print(f"✅ Task assigned successfully!")
        print(f"   Title: {resp.get('title', 'N/A')}")
        print(f"   Status: {resp.get('status', 'N/A')}")
        return True
    else:
        print(f"❌ Failed to assign task: {resp}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Agent Self-Assignment Tool")
    parser.add_argument(
        "--token",
        default=os.environ.get("MC_AGENT_TOKEN"),
        help="Agent authentication token (or set MC_AGENT_TOKEN env)",
    )
    parser.add_argument("--list", action="store_true", help="List unassigned tasks")
    parser.add_argument("--assign", metavar="TASK_ID", help="Self-assign a task by ID")
    parser.add_argument(
        "--assign-by-title",
        metavar="KEYWORD",
        help="Self-assign first unassigned task matching keyword",
    )
    parser.add_argument(
        "--my-tasks", action="store_true", help="List my assigned tasks"
    )

    args = parser.parse_args()

    if not args.token:
        print("❌ No agent token provided. Use --token or set MC_AGENT_TOKEN env")
        sys.exit(1)

    # Get agent identity
    health = get_my_identity(args.token)
    agent_id = health.get("agent_id")
    agent_name = health.get("agent_name", "Unknown")
    print(f"🤖 Authenticated as: {agent_name} ({agent_id})")
    print()

    if args.list:
        tasks = list_unassigned_tasks(args.token)
        if not tasks:
            print("📭 No unassigned tasks in inbox")
        else:
            print(f"📋 {len(tasks)} unassigned task(s):")
            for t in tasks:
                tid = t.get("id", "?")
                title = t.get("title", "Untitled")
                priority = t.get("priority", "medium")
                print(f"  [{priority:8s}] {title}")
                print(f"            ID: {tid}")

    elif args.assign:
        self_assign_task(args.token, args.assign, agent_id)

    elif args.assign_by_title:
        keyword = args.assign_by_title.lower()
        tasks = list_unassigned_tasks(args.token)
        matched = [
            t for t in tasks if keyword in t.get("title", "").lower()
        ]
        if not matched:
            print(f"📭 No unassigned tasks matching '{keyword}'")
        else:
            task = matched[0]
            print(f"📌 Found: {task.get('title')}")
            self_assign_task(args.token, task["id"], agent_id)

    elif args.my_tasks:
        tasks = list_my_tasks(args.token, agent_id)
        if not tasks:
            print("📭 No tasks assigned to you")
        else:
            print(f"📋 {len(tasks)} assigned task(s):")
            for t in tasks:
                title = t.get("title", "Untitled")
                st = t.get("status", "unknown")
                print(f"  [{st:12s}] {title}")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()

