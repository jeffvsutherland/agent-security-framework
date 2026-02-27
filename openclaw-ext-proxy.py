#!/usr/bin/env python3
"""
OpenClaw Extension Proxy - runs on the HOST Mac.

Bridges the Chrome extension to the gateway inside Docker by using
docker exec to forward TCP connections through the container's namespace.

Usage:
  python3 openclaw-ext-proxy.py        # starts proxy on 127.0.0.1:18792
  Then configure extension: ws://127.0.0.1:18792

How it works:
  1. Listens on host port 18792
  2. For each connection, spawns `docker exec -i openclaw-gateway node -e <tcp-forwarder>`
  3. Pipes data between the browser and the docker exec process's stdin/stdout
"""
import asyncio
import subprocess
import sys
import signal

LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 18792
CONTAINER = "openclaw-gateway"
TARGET_HOST = "127.0.0.1"
TARGET_PORT = 18789

# Node.js one-liner that connects to the gateway and pipes stdin/stdout
NODE_FORWARDER = (
    "const n=require('net'),"
    "c=n.connect({host:'" + TARGET_HOST + "',port:" + str(TARGET_PORT) + "},()=>{"
    "process.stdin.pipe(c);c.pipe(process.stdout)});"
    "c.on('error',()=>process.exit(1));"
    "c.on('close',()=>process.exit(0));"
    "process.stdin.on('end',()=>c.end());"
    "process.stdin.resume();"
)


async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
    peer = writer.get_extra_info("peername")

    # Spawn docker exec with node forwarder
    proc = await asyncio.create_subprocess_exec(
        "docker", "exec", "-i", CONTAINER, "node", "-e", NODE_FORWARDER,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    async def client_to_docker():
        """Forward data from Chrome extension to Docker gateway."""
        try:
            while True:
                data = await reader.read(65536)
                if not data:
                    break
                proc.stdin.write(data)
                await proc.stdin.drain()
        except (ConnectionResetError, BrokenPipeError, asyncio.CancelledError):
            pass
        finally:
            try:
                proc.stdin.close()
            except:
                pass

    async def docker_to_client():
        """Forward data from Docker gateway to Chrome extension."""
        try:
            while True:
                data = await proc.stdout.read(65536)
                if not data:
                    break
                writer.write(data)
                await writer.drain()
        except (ConnectionResetError, BrokenPipeError, asyncio.CancelledError):
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
        try:
            writer.close()
        except:
            pass


async def main():
    server = await asyncio.start_server(handle_client, LISTEN_HOST, LISTEN_PORT)
    addr = server.sockets[0].getsockname()
    print(f"🦞 OpenClaw Extension Proxy")
    print(f"   Listening: {addr[0]}:{addr[1]}")
    print(f"   Forwarding to: {CONTAINER} -> {TARGET_HOST}:{TARGET_PORT}")
    print(f"   Extension URL: ws://{addr[0]}:{addr[1]}")
    print(f"   Press Ctrl+C to stop")
    print()

    async with server:
        await server.serve_forever()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nProxy stopped.")

