#!/usr/bin/env python3
"""Simple relay diagnostic - no docker exec."""
import socket, urllib.request, urllib.error, json

OUT = "/Users/jeffsutherland/clawd/mc-relay-simple-diag.txt"
f = open(OUT, "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

def port_open(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(3)
    result = s.connect_ex((host, port))
    s.close()
    return result == 0

log("=== Simple Relay Diagnostic ===\n")

# Port checks
for port in [18789, 18792]:
    log(f"127.0.0.1:{port} = {'OPEN' if port_open('127.0.0.1', port) else 'CLOSED'}")

# HTTP checks on 18792
log("\n--- HTTP to 18792 ---")
for path in ["/", "/json", "/json/version"]:
    url = f"http://127.0.0.1:18792{path}"
    try:
        r = urllib.request.urlopen(url, timeout=5)
        log(f"  {url} -> {r.status}: {r.read().decode()[:300]}")
    except urllib.error.HTTPError as e:
        log(f"  {url} -> {e.code}: {e.read().decode()[:200]}")
    except Exception as e:
        log(f"  {url} -> {type(e).__name__}: {e}")

# HTTP checks on 18789
log("\n--- HTTP to 18789 ---")
for path in ["/", "/healthz"]:
    url = f"http://127.0.0.1:18789{path}"
    try:
        r = urllib.request.urlopen(url, timeout=5)
        log(f"  {url} -> {r.status}: {r.read().decode()[:300]}")
    except urllib.error.HTTPError as e:
        log(f"  {url} -> {e.code}: {e.read().decode()[:200]}")
    except Exception as e:
        log(f"  {url} -> {type(e).__name__}: {e}")

# Check browser config
log("\n--- Browser config ---")
try:
    with open("/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/openclaw.json") as jf:
        config = json.load(jf)
    browser = config.get("browser", "NOT SET")
    log(f"  browser: {json.dumps(browser, indent=2) if isinstance(browser, dict) else browser}")
except Exception as e:
    log(f"  Error: {e}")

log("\n=== DONE ===")
f.close()

