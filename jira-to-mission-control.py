#!/usr/bin/env python3
"""
Jira → Mission Control Task Importer
Fetches ASF stories from Jira and creates them as tasks in Mission Control.
"""
import json
import urllib.request
import urllib.error
import base64
import sys

# ── Jira Config ──
JIRA_URL = "https://frequencyfoundation.atlassian.net"
JIRA_USER = "jeff.sutherland@gmail.com"
JIRA_TOKEN = "YOUR_JIRA_TOKEN_HERE"
JIRA_PROJECT = "ASF"
JIRA_AUTH = base64.b64encode(f"{JIRA_USER}:{JIRA_TOKEN}".encode()).decode()

# ── Mission Control Config ──
MC_URL = "http://localhost:8001"
MC_TOKEN = "Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
MC_BOARD_ID = "24394a90-a74e-479c-95e8-e5d24c7b4a40"

# Agent name → MC agent ID mapping
AGENT_MAP = {
    "deploy": "30374dc0-f90b-4291-bda3-99e8db3424db",
    "research": "a752e9fc-8c0d-4a12-b455-de0a322c142f",
    "social": "b9efac34-d836-4505-b123-130502e6f42b",
    "sales": "f231fd0f-6004-4268-8dc9-d7013fcb23e9",
    "raven": "3634c19a-9174-4f23-b03a-0d451f5de6be",
    "product-owner": "3634c19a-9174-4f23-b03a-0d451f5de6be",
}

# Jira status → MC status mapping
STATUS_MAP = {
    "to do": "inbox",
    "open": "inbox",
    "backlog": "inbox",
    "in progress": "in_progress",
    "in review": "review",
    "review": "review",
    "done": "done",
    "closed": "done",
    "resolved": "done",
}

PRIORITY_MAP = {
    "highest": "critical",
    "high": "high",
    "medium": "medium",
    "low": "low",
    "lowest": "low",
}


def jira_api(path, params=None):
    """Call Jira REST API."""
    url = f"{JIRA_URL}{path}"
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={
        "Authorization": f"Basic {JIRA_AUTH}",
        "Accept": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"  JIRA ERROR {e.code}: {err[:300]}")
        return None


def mc_api(method, path, data=None):
    """Call Mission Control REST API."""
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(f"{MC_URL}{path}", data=body, method=method,
        headers={"Authorization": MC_TOKEN, "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"  MC ERROR {e.code}: {err[:300]}")
        return None


def guess_agent(issue):
    """Try to match a Jira issue to an MC agent."""
    # Check assignee
    assignee = issue.get("fields", {}).get("assignee")
    if assignee:
        name = (assignee.get("displayName") or "").lower()
        for key, agent_id in AGENT_MAP.items():
            if key in name:
                return agent_id

    # Check labels
    labels = issue.get("fields", {}).get("labels", [])
    for label in labels:
        ll = label.lower()
        for key, agent_id in AGENT_MAP.items():
            if key in ll:
                return agent_id

    # Check summary for agent keywords
    summary = (issue.get("fields", {}).get("summary") or "").lower()
    keywords = {
        "deploy": "deploy", "docker": "deploy", "infrastructure": "deploy",
        "research": "research", "scan": "research", "vulnerability": "research",
        "social": "social", "twitter": "social", "moltbook": "social", "community": "social",
        "sales": "sales", "website": "sales", "marketing": "sales", "pitch": "sales",
        "product": "raven", "sprint": "raven", "backlog": "raven",
    }
    for kw, agent_key in keywords.items():
        if kw in summary:
            return AGENT_MAP.get(agent_key)

    return None


def jira_to_mc_status(jira_status_name):
    """Convert Jira status to MC task status."""
    return STATUS_MAP.get(jira_status_name.lower(), "inbox")


def jira_to_mc_priority(jira_priority_name):
    """Convert Jira priority to MC task priority."""
    if not jira_priority_name:
        return "medium"
    return PRIORITY_MAP.get(jira_priority_name.lower(), "medium")


def fetch_jira_issues(project="ASF", max_results=100):
    """Fetch all issues from Jira project using the new search/jql API."""
    import urllib.parse
    jql = f'project = "{project}" ORDER BY key ASC'
    # New Jira API endpoint (old /search was deprecated)
    url = f"{JIRA_URL}/rest/api/3/search/jql?jql={urllib.parse.quote(jql)}&maxResults={max_results}&fields=summary,status,priority,assignee,labels,description,issuetype,created,updated"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Basic {JIRA_AUTH}",
        "Accept": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            result = json.loads(r.read())
            return result.get("issues", [])
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"  JIRA search/jql ERROR {e.code}: {err[:300]}")
        # Fallback: try POST version
        print("  Trying POST /rest/api/3/search/jql ...")
        body = json.dumps({"jql": jql, "maxResults": max_results, "fields": ["summary","status","priority","assignee","labels","description","issuetype","created","updated"]}).encode()
        req2 = urllib.request.Request(f"{JIRA_URL}/rest/api/3/search/jql", data=body, method="POST", headers={
            "Authorization": f"Basic {JIRA_AUTH}",
            "Accept": "application/json",
            "Content-Type": "application/json",
        })
        try:
            with urllib.request.urlopen(req2, timeout=30) as r:
                result = json.loads(r.read())
                return result.get("issues", [])
        except urllib.error.HTTPError as e2:
            err2 = e2.read().decode()
            print(f"  JIRA POST search ERROR {e2.code}: {err2[:300]}")
            return []


def fetch_existing_tasks():
    """Fetch existing tasks from MC board to avoid duplicates."""
    result = mc_api("GET", f"/api/v1/boards/{MC_BOARD_ID}/tasks?limit=200")
    if not result:
        return {}
    # Build lookup by title prefix (e.g. "[ASF-15]")
    lookup = {}
    for t in result.get("items", []):
        title = t.get("title", "")
        if title.startswith("[ASF-"):
            key = title.split("]")[0] + "]"
            lookup[key] = t
    return lookup


def import_issues(dry_run=False):
    """Main import: fetch Jira issues, create MC tasks."""
    print("=" * 60)
    print("  JIRA → MISSION CONTROL TASK IMPORTER")
    print("=" * 60)

    # Step 1: Test Jira connection
    print("\n📡 Testing Jira connection...")
    myself = jira_api("/rest/api/3/myself")
    if not myself:
        # Try API v2
        print("  Trying API v2...")
        myself = jira_api("/rest/api/2/myself")
    if not myself:
        print("❌ Cannot connect to Jira. Check credentials.")
        return False
    print(f"  ✅ Connected as: {myself.get('displayName', 'Unknown')}")

    # Step 2: Fetch Jira issues
    print(f"\n📋 Fetching {JIRA_PROJECT} issues from Jira...")
    issues = fetch_jira_issues(JIRA_PROJECT)
    if not issues:
        print("  ❌ No issues found or API error")
        return False
    print(f"  Found {len(issues)} issues")

    # Step 3: Check existing MC tasks
    print(f"\n🔍 Checking existing Mission Control tasks...")
    existing = fetch_existing_tasks()
    print(f"  Found {len(existing)} existing imported tasks")

    # Step 4: Import
    created = 0
    skipped = 0
    errors = 0

    print(f"\n{'DRY RUN - ' if dry_run else ''}Importing issues...\n")

    for issue in issues:
        key = issue["key"]
        fields = issue.get("fields", {})
        summary = fields.get("summary", "No summary")
        status_name = fields.get("status", {}).get("name", "To Do")
        priority_name = fields.get("priority", {}).get("name", "Medium") if fields.get("priority") else "Medium"
        issue_type = fields.get("issuetype", {}).get("name", "Story")
        description = fields.get("description")

        # Convert description from Jira ADF to plain text
        desc_text = ""
        if description:
            if isinstance(description, dict):
                # Atlassian Document Format - extract text
                for block in description.get("content", []):
                    for item in block.get("content", []):
                        if item.get("type") == "text":
                            desc_text += item.get("text", "")
                    desc_text += "\n"
            elif isinstance(description, str):
                desc_text = description
        desc_text = desc_text.strip()

        # Add Jira reference to description
        jira_link = f"{JIRA_URL}/browse/{key}"
        full_desc = f"Imported from Jira: {jira_link}\nType: {issue_type}\n\n{desc_text}" if desc_text else f"Imported from Jira: {jira_link}\nType: {issue_type}"

        tag = f"[{key}]"
        mc_status = jira_to_mc_status(status_name)
        mc_priority = jira_to_mc_priority(priority_name)
        agent_id = guess_agent(issue)

        # Skip if already imported
        if tag in existing:
            print(f"  ⏭️  {key}: {summary} (already imported)")
            skipped += 1
            continue

        task_data = {
            "title": f"{tag} {summary}",
            "description": full_desc,
            "status": mc_status,
            "priority": mc_priority,
        }
        if agent_id and mc_status != "done":
            task_data["assigned_agent_id"] = agent_id

        status_icon = {"inbox": "📥", "in_progress": "🔄", "review": "👀", "done": "✅"}.get(mc_status, "❓")
        agent_label = f" → {agent_id[:8]}..." if agent_id else ""
        print(f"  {status_icon} {key}: {summary} [{mc_status}]{agent_label}")

        if not dry_run:
            result = mc_api("POST", f"/api/v1/boards/{MC_BOARD_ID}/tasks", task_data)
            if result:
                created += 1
            else:
                errors += 1
                print(f"      ❌ Failed to create task")
        else:
            created += 1

    # Summary
    print(f"\n{'=' * 60}")
    print(f"  {'DRY RUN ' if dry_run else ''}IMPORT COMPLETE")
    print(f"  Created: {created}")
    print(f"  Skipped (duplicates): {skipped}")
    print(f"  Errors: {errors}")
    print(f"  Total Jira issues: {len(issues)}")
    print(f"{'=' * 60}")
    return True


if __name__ == "__main__":
    dry_run = "--dry-run" in sys.argv or "-n" in sys.argv
    if dry_run:
        print("🏃 DRY RUN MODE — no tasks will be created\n")
    import_issues(dry_run=dry_run)

