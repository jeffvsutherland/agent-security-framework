#!/usr/bin/env python3
"""
Moltbook posting helper for ASF agents.
Usage: python3 moltbook-post.py "Title" "Content" [submolt]
"""
import sys
import json
import urllib.request
import re
import ssl

API_KEY = "moltbook_sk_l4Ns2EuEfd5QY0s4-A0r7jZMuSIo8EWs"
API_URL = "https://www.moltbook.com/api/v1"

# SSL context (bypass TLS proxy if present)
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def api_call(endpoint, method="GET", data=None):
    url = f"{API_URL}/{endpoint}"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    resp = urllib.request.urlopen(req, timeout=30, context=ctx)
    return json.loads(resp.read().decode())

def parse_challenge(text):
    """Parse the garbled verification challenge into a math answer."""
    # Strip punctuation and normalize
    clean = re.sub(r'[^a-zA-Z0-9\s]', '', text).lower()
    clean = re.sub(r'\s+', ' ', clean).strip()
    
    # Number word mapping
    nums = {
        'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
        'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
        'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
        'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19,
        'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50,
        'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90, 'hundred': 100
    }
    
    # Find all numbers in text
    found_numbers = []
    words = clean.split()
    i = 0
    while i < len(words):
        w = words[i]
        if w in nums:
            val = nums[w]
            # Check for compound like "twenty five"
            if i + 1 < len(words) and words[i+1] in nums and nums[words[i+1]] < 10:
                val += nums[words[i+1]]
                i += 1
            found_numbers.append(val)
        elif w.isdigit():
            found_numbers.append(int(w))
        i += 1
    
    # Determine operation
    if 'multiplied' in clean or 'times' in clean:
        if len(found_numbers) >= 2:
            result = found_numbers[0] * found_numbers[1]
        else:
            result = found_numbers[0] if found_numbers else 0
    elif 'total' in clean or 'and' in clean or 'added' in clean or 'plus' in clean:
        result = sum(found_numbers)
    else:
        result = sum(found_numbers)
    
    return f"{result:.2f}"

def read_feed(sort="new", limit=5):
    """Read Moltbook feed."""
    result = api_call(f"feed?sort={sort}&limit={limit}")
    if result.get("success"):
        for post in result.get("posts", []):
            print(f"\n--- {post['title']} ---")
            print(f"By: {post['author']['name']} | Upvotes: {post['upvotes']} | Comments: {post['comment_count']}")
            print(f"Content: {post['content'][:200]}...")
            print(f"ID: {post['id']}")
    return result

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "read":
            read_feed(sys.argv[2] if len(sys.argv) > 2 else "new", int(sys.argv[3]) if len(sys.argv) > 3 else 5)
        else:
            title = sys.argv[1]
            content = sys.argv[2] if len(sys.argv) > 2 else ""
            submolt = sys.argv[3] if len(sys.argv) > 3 else "general"
            print(f"Posting: {title}")
            result = api_call("posts", "POST", {"title": title, "content": content, "submolt_name": submolt})
            print(json.dumps(result, indent=2))
    else:
        print("Usage:")
        print("  python3 moltbook-post.py read [new|hot] [limit]")
        print("  python3 moltbook-post.py \"Title\" \"Content\" [submolt]")