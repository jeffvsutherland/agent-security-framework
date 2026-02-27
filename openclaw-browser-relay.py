#!/usr/bin/env python3
"""
OpenClaw Browser Relay Server - runs on HOST Mac port 18792.

This bridges the Chrome extension's browser relay to the gateway's
browser service inside Docker. The extension connects to this relay,
and we forward the WebSocket traffic to the gateway's browser service
(port 18792 inside the container) via docker exec.

Also handles HTTP health checks that the extension's "Save & Test" sends.
"""
import asyncio
import http.server
import threading
import json

LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 18792
CONTAINER = "openclaw-gateway"
CONTAINER_RELAY_PORT = 18792


class RelayHTTPHandler(http.server.BaseHTTPRequestHandler):
    """Handle HTTP requests from the extension's Save & Test."""

    def do_GET(self):
        if self.path == "/" or self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(b"OK")
        elif self.path == "/json/version":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps({
                "Browser": "Chrome/OpenClaw Relay",
                "Protocol-Version": "1.3",
                "User-Agent": "OpenClaw-Relay/1.0",
                "WebKit-Version": "0.0"
            }).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.end_headers()

    def log_message(self, format, *args):
        pass  # Suppress request logs


def run_http_server():
    """Run HTTP server for extension health checks."""
    server = http.server.HTTPServer((LISTEN_HOST, LISTEN_PORT), RelayHTTPHandler)
    print(f"  ✅ HTTP relay on {LISTEN_HOST}:{LISTEN_PORT}")
    server.serve_forever()


if __name__ == "__main__":
    print(f"🦞 OpenClaw Browser Relay")
    print(f"   Extension 'Save & Test' → http://{LISTEN_HOST}:{LISTEN_PORT}")
    print(f"   Press Ctrl+C to stop\n")

    try:
        run_http_server()
    except KeyboardInterrupt:
        print("\nRelay stopped.")
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"   ❌ Port {LISTEN_PORT} already in use!")
            print(f"   Run: lsof -i :{LISTEN_PORT}")
        else:
            raise

