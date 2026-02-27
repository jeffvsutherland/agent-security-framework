#!/usr/bin/env python3
"""Test both proxies and the relay HTTP endpoint."""
import socket, urllib.request, urllib.error, time

time.sleep(3)
OUT = "/Users/jeffsutherland/clawd/copilot_out.txt"
f = open(OUT, "w")

# Port check
for port in [18792, 18793]:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(3)
    r = s.connect_ex(("127.0.0.1", port))
    s.close()
    f.write(f"{port}: {'OPEN' if r==0 else 'CLOSED'}\n")

# HTTP test on 18792 (what the extension's Save & Test does)
for url in ["http://127.0.0.1:18792/", "http://127.0.0.1:18792/json/version"]:
    try:
        r = urllib.request.urlopen(url, timeout=5)
        f.write(f"GET {url} -> {r.status}: {r.read().decode()[:200]}\n")
    except urllib.error.HTTPError as e:
        f.write(f"GET {url} -> HTTP {e.code}: {e.read().decode()[:100]}\n")
    except Exception as e:
        f.write(f"GET {url} -> {type(e).__name__}: {e}\n")

# WS test on 18793
try:
    import websocket
    ws = websocket.create_connection(
        "ws://127.0.0.1:18793", timeout=10,
        header=["Authorization: Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0"],
        origin="chrome-extension://bfpnaggikhabdgbnhnngdfldkbinncdf"
    )
    msg = ws.recv()
    f.write(f"WS 18793: CONNECTED - {msg[:200]}\n")
    ws.close()
except Exception as e:
    f.write(f"WS 18793: {type(e).__name__}: {e}\n")

f.close()

