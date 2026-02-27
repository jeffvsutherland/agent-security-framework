#!/usr/bin/env python3
"""Quick verify: relay on 18792, proxy on 18793."""
import socket, urllib.request

OUTFILE = "/Users/jeffsutherland/clawd/mc-relay-verify.txt"
results = []

for port in [18792, 18793]:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2)
    rc = s.connect_ex(("127.0.0.1", port))
    s.close()
    results.append(f"{port}: {'OPEN' if rc==0 else 'CLOSED'}")

# HTTP test on 18792 (what extension Save & Test does)
try:
    r = urllib.request.urlopen("http://127.0.0.1:18792/", timeout=5)
    results.append(f"HTTP GET /: {r.status} {r.read().decode()}")
except Exception as e:
    results.append(f"HTTP GET /: FAILED {e}")

try:
    r = urllib.request.urlopen("http://127.0.0.1:18792/json/version", timeout=5)
    results.append(f"HTTP GET /json/version: {r.status} {r.read().decode()[:100]}")
except Exception as e:
    results.append(f"HTTP GET /json/version: FAILED {e}")

with open(OUTFILE, "w") as f:
    f.write("\n".join(results) + "\n")
print(f"Results: {OUTFILE}")

