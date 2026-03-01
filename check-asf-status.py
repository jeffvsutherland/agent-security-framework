#!/usr/bin/env python3
"""
Check ASF story status - fetches LIVE data from Mission Control API.
Works both on host (localhost:8001) and in Docker (host.docker.internal:8001).

Usage:
    python3 check-asf-status.py                # Show all tasks summary
    python3 check-asf-status.py ASF-33         # Check specific story
    python3 check-asf-status.py --status done  # Filter by status
    python3 check-asf-status.py --summary      # Board summary only
"""
import sys
import json
import os
import re
import argparse
import urllib.request
import urllib.error

AGENT_TOKEN = "WeWnFbK9IoknRjXFPGsV-xHlgGJkXZNcfgltKCQasFQ"
BOARD_ID = "24394a90-a74e-479c-95e8-e5d24c7b4a40"
MC_URLS = ["http://host.docker.internal:8001", "http://localhost:8001"]


def get_mc_url():
    """Find working Mission Control URL."""
    for url in MC_URLS:
        try:
            req = urllib.request.Request(
                f"{url}/health",
                headers={"Authorization": f"Bearer {AGENT_TOKEN}"},
            )
            resp = urllib.request.urlopen(req, timeout=5)
            data = json.loads(resp.read())
            if data.get("ok"):
                return url
        except Exception:
            continue
    return None


def fetch_tasks(mc_url):
    """Fetch all tasks from Mission Control API."""
    url = f"{mc_url}/api/v1/agent/boards/{BOARD_ID}/tasks"
    req = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Bearer {AGENT_TOKEN}",
            "Content-Type": "application/json",
        },
    )
    try:
        resp = urllib.request.urlopen(req, timeout=15)
        return json.loads(resp.read()).get("items", [])
    except urllib.error.HTTPError as e:
        print(f"API error: HTTP {e.code} - {e.reason}")
        return []
    except Exception as e:
        print(f"Connection error: {e}")
        return []


def format_status_emoji(status):
    """Map Mission Control status to emoji."""
    return {
        "inbox": "📥", "to_do": "📋", "in_progress": "🔄",
        "in_review": "👀", "done": "✅", "blocked": "🚫",
    }.get(status, "❓")


def check_story_status(tasks, story_id):
    """Find and display a specific story by ASF-XX ID."""
    story_id = story_id.upper()
    matches = [t for t in tasks if story_id in (t.get("title", "") or "").upper()]
    if not matches:
        print(f"Story {story_id} not found in Mission Control board.")
        return
    for task in matches:
        emoji = format_status_emoji(task.get("status", ""))
        print(f"{emoji} {task.get('title', 'Untitled')}")
        print(f"   Status: {task.get('status', 'unknown')}")
        print(f"   Priority: {task.get('priority', 'N/A')} | Points: {task.get('story_points') or 'N/A'}")
        print(f"   Assignee: {task.get('assigned_agent_id') or 'Unassigned'}")
        print(f"   ID: {task.get('id', 'N/A')[:8]}...")
        print(f"   Updated: {task.get('updated_at', 'N/A')[:19]}")
        print()


def show_board_summary(tasks):
    """Show board summary with counts by status."""
    counts = {}
    for t in tasks:
        s = t.get("status", "unknown")
        counts[s] = counts.get(s, 0) + 1
    total = len(tasks)
    print("=" * 55)
    print("ASF Board Summary (LIVE from Mission Control)")
    print("=" * 55)
    print(f"   Total tasks: {total}")
    print()
    for s in ["inbox", "to_do", "in_progress", "in_review", "done", "blocked"]:
        if s in counts:
            emoji = format_status_emoji(s)
            pct = (counts[s] / total * 100) if total else 0
            bar = chr(9608) * int(pct / 5)
            print(f"   {emoji} {s:15s} {counts[s]:3d}  ({pct:5.1f}%) {bar}")
    for s, c in sorted(counts.items()):
        if s not in ["inbox", "to_do", "in_progress", "in_review", "done", "blocked"]:
            pct = (c / total * 100) if total else 0
            print(f"   ? {s:15s} {c:3d}  ({pct:5.1f}%)")
    print()


def show_tasks_by_status(tasks, status_filter=None):
    """List tasks, optionally filtered by status."""
    if status_filter:
        tasks = [t for t in tasks if t.get("status") == status_filter]
    if not tasks:
        sf = f" with status: {status_filter}" if status_filter else ""
        print(f"No tasks found{sf}.")
        return
    grouped = {}
    for t in tasks:
        grouped.setdefault(t.get("status", "unknown"), []).append(t)
    for s in ["inbox", "to_do", "in_progress", "in_review", "done", "blocked"]:
        if s not in grouped:
            continue
        emoji = format_status_emoji(s)
        print(f"\n{emoji} {s.upper()} ({len(grouped[s])})")
        print("-" * 50)
        for t in grouped[s]:
            title = t.get("title", "Untitled")
            prio = {"high": "R", "medium": "Y", "low": "G"}.get(t.get("priority", "?"), " ")
            if len(title) > 65:
                title = title[:62] + "..."
            print(f"  [{prio}] {title}")
    for s, items in sorted(grouped.items()):
        if s not in ["inbox", "to_do", "in_progress", "in_review", "done", "blocked"]:
            print(f"\n? {s.upper()} ({len(items)})")
            print("-" * 50)
            for t in items:
                print(f"  [ ] {t.get('title', 'Untitled')[:65]}")


def main():
    parser = argparse.ArgumentParser(
        description="Check ASF story status from Mission Control (LIVE)"
    )
    parser.add_argument("story_id", nargs="?", help="ASF story ID (e.g. ASF-33)")
    parser.add_argument("--status", "-s", help="Filter by status")
    parser.add_argument("--summary", action="store_true", help="Board summary only")
    args = parser.parse_args()

    mc_url = get_mc_url()
    if not mc_url:
        print("Cannot reach Mission Control API.")
        print("   Tried: " + ", ".join(MC_URLS))
        print("   Check: docker ps | grep mission-control")
        sys.exit(1)

    print(f"Connected to Mission Control: {mc_url}")
    print()

    tasks = fetch_tasks(mc_url)
    if not tasks:
        print("No tasks returned from Mission Control.")
        sys.exit(1)

    if args.story_id:
        check_story_status(tasks, args.story_id)
    elif args.summary:
        show_board_summary(tasks)
    else:
        show_board_summary(tasks)
        show_tasks_by_status(tasks, args.status)


if __name__ == "__main__":
    main()
