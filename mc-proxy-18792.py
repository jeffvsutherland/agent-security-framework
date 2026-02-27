#!/usr/bin/env python3
"""Start a node TCP proxy inside the gateway container on port 18792 -> 18789.
Port 18792 is already exposed to the host from the container recreation."""
import subprocess, socket, time

OUT = "/Users/jeffsutherland/clawd/mc-proxy-18792.txt"
f = open(OUT, "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

log("=== Setting up proxy on 18792 -> 18789 inside container ===\n")

# Kill any existing proxy on 18792
subprocess.run(
    ["docker", "exec", "openclaw-gateway", "sh", "-c",
     "kill $(lsof -ti:18792) 2>/dev/null; true"],
    capture_output=True, text=True, timeout=5
)

# Write and start node TCP proxy
proxy_code = r"""
const net = require('net');
const server = net.createServer((client) => {
  const target = net.connect(18789, '127.0.0.1', () => {
    client.pipe(target);
    target.pipe(client);
  });
  target.on('error', () => client.destroy());
  client.on('error', () => target.destroy());
});
server.listen(18792, '0.0.0.0', () => {
  console.log('Proxy: 0.0.0.0:18792 -> 127.0.0.1:18789');
});
"""

r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "sh", "-c",
     f"cat > /tmp/ws-proxy-18792.js << 'EOF'\n{proxy_code}\nEOF"],
    capture_output=True, text=True, timeout=5
)
log(f"Wrote script: rc={r.returncode}")

r = subprocess.run(
    ["docker", "exec", "-d", "openclaw-gateway", "node", "/tmp/ws-proxy-18792.js"],
    capture_output=True, text=True, timeout=5
)
log(f"Started proxy: rc={r.returncode}")

time.sleep(2)

# Test internally
r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "node", "-e",
     """
const http = require('http');
http.get('http://0.0.0.0:18792/', (res) => {
  let d = '';
  res.on('data', c => d += c);
  res.on('end', () => console.log('INTERNAL OK status=' + res.statusCode));
}).on('error', e => console.log('INTERNAL ERR: ' + e.message));
"""],
    capture_output=True, text=True, timeout=10
)
log(f"Internal test: {r.stdout.strip()}")

# Test WebSocket internally
r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "node", "-e",
     """
const WebSocket = require('ws');
const ws = new WebSocket('ws://0.0.0.0:18792', {
  headers: { 'Authorization': 'Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0' }
});
ws.on('open', () => { console.log('WS_OK'); ws.close(); process.exit(0); });
ws.on('error', e => { console.log('WS_ERR: ' + e.message); process.exit(1); });
setTimeout(() => { console.log('WS_TIMEOUT'); process.exit(1); }, 5000);
"""],
    capture_output=True, text=True, timeout=10
)
log(f"Internal WS test: {r.stdout.strip()}")

# Test from host
log("\n--- Testing from host ---")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(5)
r = s.connect_ex(("127.0.0.1", 18792))
s.close()
log(f"Port 18792 from host: {'OPEN' if r==0 else 'CLOSED'}")

if r == 0:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect(("127.0.0.1", 18792))
        upgrade = (
            "GET / HTTP/1.1\r\n"
            "Host: 127.0.0.1:18792\r\n"
            "Connection: keep-alive\r\n"
            "\r\n"
        )
        s.sendall(upgrade.encode())
        response = s.recv(4096)
        log(f"HTTP response: {response[:300]}")
        s.close()
    except Exception as e:
        log(f"HTTP error: {type(e).__name__}: {e}")

    # Test WS from host
    try:
        import websocket
        ws = websocket.create_connection(
            "ws://127.0.0.1:18792",
            timeout=5,
            header=["Authorization: Bearer uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0"]
        )
        log("HOST WS: CONNECTED!")
        msg = ws.recv()
        log(f"HOST WS msg: {msg[:300]}")
        ws.close()
    except Exception as e:
        log(f"HOST WS error: {type(e).__name__}: {e}")
else:
    log("Port 18792 not reachable from host - container may need -p 18792:18792")

log("\n=== DONE ===")
f.close()

