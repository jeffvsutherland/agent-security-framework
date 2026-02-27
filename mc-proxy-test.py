#!/usr/bin/env python3
"""Test the host-side proxy."""
import socket, time

OUT = "/Users/jeffsutherland/clawd/mc-proxy-test.txt"
f = open(OUT, "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

log("=== Testing host proxy on 18792 ===\n")

# Check port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(3)
r = s.connect_ex(("127.0.0.1", 18792))
s.close()
log(f"Port 18792: {'OPEN' if r==0 else 'CLOSED'}")

if r == 0:
    # Test WebSocket
    try:
        import websocket
        ws = websocket.create_connection(
            "ws://127.0.0.1:18792",
            timeout=10,
            header=["Authorization: Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0"]
        )
        log("WS: CONNECTED!")
        msg = ws.recv()
        log(f"WS msg: {msg[:500]}")
        ws.close()
        log("SUCCESS - Extension should work now!")
    except Exception as e:
        log(f"WS: {type(e).__name__}: {e}")
else:
    log("Proxy not listening. May need to check if port is in use.")
    # Check what's on 18792
    import subprocess
    r = subprocess.run(["lsof", "-i", ":18792"], capture_output=True, text=True)
    log(f"lsof: {r.stdout[:300]}")

log("\n=== DONE ===")
f.close()

