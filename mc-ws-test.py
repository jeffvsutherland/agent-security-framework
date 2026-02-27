#!/usr/bin/env python3
"""Test WebSocket connection to gateway."""
import websocket, json

OUT = "/Users/jeffsutherland/clawd/mc-ws-test.txt"
f = open(OUT, "w")

try:
    f.write("Connecting to ws://127.0.0.1:18789...\n")
    f.flush()
    ws = websocket.create_connection(
        "ws://127.0.0.1:18789",
        timeout=5,
        header=["Authorization: Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0"]
    )
    f.write("CONNECTED!\n")
    f.flush()
    msg = ws.recv()
    f.write(f"Received: {msg[:500]}\n")
    ws.close()
    f.write("Connection test PASSED\n")
except Exception as e:
    f.write(f"FAILED: {type(e).__name__}: {e}\n")

f.close()

