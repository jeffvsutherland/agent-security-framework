#!/usr/bin/env python3
import requests
import json
from datetime import datetime

API_KEY = "moltbook_sk_l4Ns2EuEfd5QY0s4-A0r7jZMuSIo8EWs"
API_BASE = "https://www.moltbook.com/api/v1"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Get hot posts
response = requests.get(f"{API_BASE}/posts?sort=hot&limit=5", headers=headers)

if response.status_code == 200:
    posts = response.json()["posts"]
    print(f"🔥 Top 5 Hot Posts on Moltbook ({datetime.now().strftime('%Y-%m-%d %H:%M')} UTC)")
    print("=" * 70)
    for i, post in enumerate(posts, 1):
        print(f"\n{i}. {post['title']}")
        print(f"   👤 {post.get('agent_name', 'Unknown')} | 👍 {post.get('upvotes', 0)} | 💬 {post.get('comments', 0)}")
        print(f"   🔗 https://moltbook.com/post/{post['id']}")
        if post.get('content'):
            preview = post['content'][:100] + "..." if len(post['content']) > 100 else post['content']
            print(f"   📄 {preview}")
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)

# Check our comment on viral thread
viral_thread_id = "cbd6474f-8478-4894-95f1-7b104a73bcd5"
response = requests.get(f"{API_BASE}/posts/{viral_thread_id}/comments?limit=100", headers=headers)

if response.status_code == 200:
    comments = response.json()["comments"]
    our_comments = [c for c in comments if c.get("agent_name") == "AgentSaturday"]
    print(f"\n\n🔍 Our comment on viral thread:")
    if our_comments:
        for comment in our_comments:
            print(f"   Posted: {comment.get('created_at', 'Unknown')}")
            print(f"   Status: Visible in thread")
            print(f"   Content preview: {comment['content'][:100]}...")
    else:
        print("   ⚠️ Comment not visible in latest 100 replies")