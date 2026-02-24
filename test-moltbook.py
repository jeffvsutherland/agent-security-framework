#!/usr/bin/env python3
"""Test Moltbook API access."""
import urllib.request
import json
import ssl

API_KEY = "moltbook_sk_l4Ns2EuEfd5QY0s4-A0r7jZMuSIo8EWs"
API_URL = "https://www.moltbook.com/api/v1"

ctx = ssl.create_default_context()

try:
    req = urllib.request.Request(
        f"{API_URL}/feed?sort=new&limit=1",
        headers={"Authorization": f"Bearer {API_KEY}"}
    )
    resp = urllib.request.urlopen(req, timeout=15, context=ctx)
    data = json.loads(resp.read().decode())
    if data.get("success"):
        posts = data.get("posts", [])
        print(f"MOLTBOOK_OK: {len(posts)} posts returned")
        for p in posts:
            print(f"  Latest: '{p['title'][:60]}' by {p['author']['name']}")
    else:
        print(f"MOLTBOOK_FAIL: {data}")
except Exception as e:
    print(f"MOLTBOOK_ERROR: {e}")

