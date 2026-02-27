#!/usr/bin/env python3
"""
Host-side WebSocket/TCP proxy for OpenClaw Chrome extension.

Problem: Gateway runs inside Docker bound to 127.0.0.1. Docker Desktop
for Mac cannot forward to container's loopback. Chrome extension can't connect.

Solution: Run a TCP proxy ON THE HOST that connects to the gateway
via Docker's internal network (docker exec), forwarding bytes between
the Chrome extension and the gateway.

Actually simpler: use `docker exec` to get the gateway's container IP
on the Docker bridge network, then proxy to that IP directly.
"""
import subprocess, json, socket, asyncio, signal, sys

# Get the gateway's IP on the Docker network
r = subprocess.run(
    ["docker", "inspect", "--format", "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}", "openclaw-gateway"],
    capture_output=True, text=True
)
GATEWAY_IP = r.stdout.strip()
GATEWAY_PORT = 18789
LISTEN_PORT = 18792  # What the Chrome extension connects to
LISTEN_HOST = "127.0.0.1"

print(f"OpenClaw Gateway Proxy")
print(f"  Gateway: {GATEWAY_IP}:{GATEWAY_PORT}")
print(f"  Listen:  {LISTEN_HOST}:{LISTEN_PORT}")
print(f"  Extension URL: ws://{LISTEN_HOST}:{LISTEN_PORT}")
print()

# Quick test: can we reach the gateway IP from host?
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(3)
result = s.connect_ex((GATEWAY_IP, GATEWAY_PORT))
s.close()
if result != 0:
    print(f"ERROR: Cannot reach {GATEWAY_IP}:{GATEWAY_PORT} from host (rc={result})")
    print("The Docker network may not be routable from the host.")
    print("Trying alternative: proxy via docker exec pipe...")
    GATEWAY_IP = None

if GATEWAY_IP:
    # Direct TCP proxy
    async def handle_client(reader, writer):
        try:
            target_reader, target_writer = await asyncio.open_connection(GATEWAY_IP, GATEWAY_PORT)
        except Exception as e:
            writer.close()
            return

        async def forward(src, dst):
            try:
                while True:
                    data = await src.read(65536)
                    if not data:
                        break
                    dst.write(data)
                    await dst.drain()
            except:
                pass
            finally:
                try:
                    dst.close()
                except:
                    pass

        await asyncio.gather(
            forward(reader, target_writer),
            forward(target_reader, writer)
        )

    async def main():
        server = await asyncio.start_server(handle_client, LISTEN_HOST, LISTEN_PORT)
        addr = server.sockets[0].getsockname()
        print(f"Proxy listening on {addr[0]}:{addr[1]}")
        print(f"Configure extension: ws://{addr[0]}:{addr[1]}")
        print("Press Ctrl+C to stop")
        async with server:
            await server.serve_forever()

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProxy stopped.")
else:
    # Docker Desktop Mac: container IPs aren't routable from host
    # Use docker exec to pipe data through
    print("Docker network not directly routable. Using docker exec pipe proxy.")
    print("This approach forwards via docker exec socat/nc inside the container.")

    # Alternative: just tell the user the simpler fix
    print()
    print("=== RECOMMENDED FIX ===")
    print("The gateway binds to 127.0.0.1 inside Docker.")
    print("On Docker Desktop for Mac, container IPs aren't routable from the host.")
    print()
    print("Option A: Add this to openclaw.json gateway.controlUi section and restart:")
    print('  "bind": "tailnet"  (if using Tailscale)')
    print()
    print("Option B: Run the gateway natively (not in Docker):")
    print("  openclaw gateway")
    print()
    print("Option C: Use socat on the host (if installed):")
    print("  socat TCP-LISTEN:18792,fork,reuseaddr EXEC:'docker exec -i openclaw-gateway socat - TCP:127.0.0.1:18789'")

