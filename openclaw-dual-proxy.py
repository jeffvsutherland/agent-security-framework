#!/usr/bin/env python3
"""
OpenClaw Dual Proxy - runs on the HOST Mac.

Bridges BOTH the Chrome extension relay AND gateway WS to the Docker container.

Port 18792 (host) -> 18792 (container) = Browser relay (CDP tab sharing)
Port 18793 (host) -> 18789 (container) = Gateway WebSocket (agent communication)

Extension settings:
  Relay Port: 18792
  WebSocket URL: ws://127.0.0.1:18793
"""
import asyncio
import subprocess
import sys

CONTAINER = "openclaw-gateway"

# Proxy configs: (host_port, container_target_port, description)
PROXIES = [
    (18792, 18792, "Browser Relay (CDP)"),
    (18793, 18789, "Gateway WebSocket"),
]


def make_node_forwarder(target_host, target_port):
    """Node.js script that pipes stdin/stdout to a TCP target."""
    return (
        f"const n=require('net'),"
        f"c=n.connect({{host:'{target_host}',port:{target_port}}},()=>{{"
        f"process.stdin.pipe(c);c.pipe(process.stdout)}});"
        f"c.on('error',()=>process.exit(1));"
        f"c.on('close',()=>process.exit(0));"
        f"process.stdin.on('end',()=>c.end());"
        f"process.stdin.resume();"
    )


async def handle_client(reader, writer, target_port, desc):
    node_code = make_node_forwarder("127.0.0.1", target_port)

    try:
        proc = await asyncio.create_subprocess_exec(
            "docker", "exec", "-i", CONTAINER, "node", "-e", node_code,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
    except Exception as e:
        writer.close()
        return

    async def client_to_docker():
        try:
            while True:
                data = await reader.read(65536)
                if not data:
                    break
                proc.stdin.write(data)
                await proc.stdin.drain()
        except:
            pass
        finally:
            try:
                proc.stdin.close()
            except:
                pass

    async def docker_to_client():
        try:
            while True:
                data = await proc.stdout.read(65536)
                if not data:
                    break
                writer.write(data)
                await writer.drain()
        except:
            pass
        finally:
            try:
                writer.close()
            except:
                pass

    try:
        await asyncio.gather(client_to_docker(), docker_to_client())
    except:
        pass
    finally:
        try:
            proc.kill()
        except:
            pass


async def main():
    servers = []
    for host_port, target_port, desc in PROXIES:
        handler = lambda r, w, tp=target_port, d=desc: handle_client(r, w, tp, d)
        try:
            server = await asyncio.start_server(handler, "127.0.0.1", host_port)
            servers.append(server)
            print(f"  ✅ :{host_port} -> container:{target_port}  ({desc})")
        except OSError as e:
            print(f"  ❌ :{host_port} -> container:{target_port}  ({desc}) - {e}")

    if not servers:
        print("\nNo proxies started!")
        return

    print(f"\n  Extension settings:")
    print(f"    Relay Port: 18792")
    print(f"    WebSocket URL: ws://127.0.0.1:18793")
    print(f"    Gateway Token: uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0")
    print(f"\n  Press Ctrl+C to stop\n")

    await asyncio.gather(*[s.serve_forever() for s in servers])


if __name__ == "__main__":
    print(f"🦞 OpenClaw Dual Proxy\n")
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProxy stopped.")

