#!/usr/bin/env python3
"""Fix: start a proper proxy on 0.0.0.0:18792 inside the gateway container."""
import subprocess, socket, time

OUT = "/Users/jeffsutherland/clawd/mc-proxy-fix-final.txt"
f = open(OUT, "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

log("=== Fix proxy on 0.0.0.0:18792 ===\n")

# Kill any existing node processes on 18792
subprocess.run(
    ["docker", "exec", "openclaw-gateway", "sh", "-c",
     "pkill -f ws-proxy-18792 2>/dev/null; pkill -f ws-proxy.js 2>/dev/null; sleep 1"],
    capture_output=True, text=True, timeout=10
)

# Write a fresh proxy script that explicitly logs bind success
proxy_js = """
const net = require('net');
const server = net.createServer((client) => {
  const target = net.connect({host: '127.0.0.1', port: 18789}, () => {
    client.pipe(target);
    target.pipe(client);
  });
  target.on('error', (e) => { try{client.destroy()}catch(x){} });
  client.on('error', (e) => { try{target.destroy()}catch(x){} });
});
server.on('error', (e) => {
  console.error('Server error:', e.message);
  process.exit(1);
});
server.listen({host: '0.0.0.0', port: 18792, exclusive: true}, () => {
  const addr = server.address();
  console.log('PROXY_BOUND host=' + addr.address + ' port=' + addr.port);
});
"""

r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "sh", "-c",
     f"cat > /tmp/gateway-proxy.js << 'PROXYEOF'\n{proxy_js}\nPROXYEOF"],
    capture_output=True, text=True, timeout=5
)
log(f"Wrote script: rc={r.returncode}")

# Start it in foreground briefly to capture the bind output, then background it
r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "timeout", "3", "node", "/tmp/gateway-proxy.js"],
    capture_output=True, text=True, timeout=10
)
log(f"Test run output: {r.stdout.strip()}")
log(f"Test run stderr: {r.stderr.strip()[:200]}")

# Now start for real in background
r = subprocess.run(
    ["docker", "exec", "-d", "openclaw-gateway", "node", "/tmp/gateway-proxy.js"],
    capture_output=True, text=True, timeout=5
)
log(f"Background start: rc={r.returncode}")
time.sleep(2)

# Verify it's actually on 0.0.0.0:18792
r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "sh", "-c",
     "cat /proc/net/tcp | awk '{print $2}' | while read x; do "
     "port=$((16#${x##*:})); addr=${x%%:*}; "
     "if [ $port -eq 18792 ] || [ $port -eq 18789 ] || [ $port -eq 18790 ]; then "
     "echo \"hex=$x dec_port=$port\"; fi; done"],
    capture_output=True, text=True, timeout=10
)
log(f"\nPorts inside container:\n{r.stdout}")

# Test from host
log("--- Host tests ---")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(5)
r = s.connect_ex(("127.0.0.1", 18792))
s.close()
log(f"18792 TCP: {'OPEN' if r==0 else 'CLOSED'}")

if r == 0:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect(("127.0.0.1", 18792))
        req = (
            "GET / HTTP/1.1\r\n"
            "Host: 127.0.0.1:18792\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
            "Sec-WebSocket-Version: 13\r\n"
            "Authorization: Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0\r\n"
            "\r\n"
        )
        s.sendall(req.encode())
        resp = s.recv(4096)
        log(f"WS upgrade response: {resp[:400]}")
        s.close()
    except Exception as e:
        log(f"WS upgrade error: {type(e).__name__}: {e}")

    try:
        import websocket
        ws = websocket.create_connection(
            "ws://127.0.0.1:18792",
            timeout=5,
            header=["Authorization: Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0"]
        )
        log("WS CONNECTED!")
        msg = ws.recv()
        log(f"WS msg: {msg[:300]}")
        ws.close()
    except Exception as e:
        log(f"WS error: {type(e).__name__}: {e}")

log("\n=== DONE ===")
f.close()

