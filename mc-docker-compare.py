#!/usr/bin/env python3
"""Compare gateway vs backend Docker networking to understand why 8001 works but 18789 doesn't."""
import subprocess, json

OUT = "/Users/jeffsutherland/clawd/mc-docker-compare.txt"
f = open(OUT, "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

log("=== Docker Networking Comparison ===\n")

for name in ["openclaw-mission-control-backend-1", "openclaw-gateway"]:
    log(f"--- {name} ---")
    r = subprocess.run(
        ["docker", "inspect", "--format",
         "Ports: {{json .NetworkSettings.Ports}}\nBindings: {{json .HostConfig.PortBindings}}\nNetworkMode: {{.HostConfig.NetworkMode}}\nNetworks: {{json .NetworkSettings.Networks}}",
         name],
        capture_output=True, text=True, timeout=10
    )
    log(r.stdout[:1000])
    log("")

# Check if the gateway network is different
r = subprocess.run(["docker", "network", "ls", "--format", "{{.Name}}"],
                    capture_output=True, text=True, timeout=5)
log(f"Docker networks: {r.stdout.strip()}")

# Check gateway network details
r = subprocess.run(["docker", "network", "inspect", "asf-network"],
                    capture_output=True, text=True, timeout=10)
try:
    net = json.loads(r.stdout)
    if net:
        log(f"\nasf-network driver: {net[0].get('Driver')}")
        log(f"asf-network IPAM: {json.dumps(net[0].get('IPAM', {}), indent=2)}")
        containers = net[0].get("Containers", {})
        for cid, info in containers.items():
            log(f"  Container: {info.get('Name')} IP: {info.get('IPv4Address')}")
except:
    pass

# Check mission-control network
r = subprocess.run(
    ["docker", "inspect", "--format", "{{.HostConfig.NetworkMode}}", "openclaw-mission-control-backend-1"],
    capture_output=True, text=True, timeout=5
)
log(f"\nBackend network mode: {r.stdout.strip()}")

r = subprocess.run(
    ["docker", "inspect", "--format", "{{.HostConfig.NetworkMode}}", "openclaw-gateway"],
    capture_output=True, text=True, timeout=5
)
log(f"Gateway network mode: {r.stdout.strip()}")

# KEY TEST: Check if the MC backend binds to 0.0.0.0 inside its container
r = subprocess.run(
    ["docker", "exec", "openclaw-mission-control-backend-1", "sh", "-c",
     "cat /proc/net/tcp 2>/dev/null | head -5 || ss -tlnp 2>/dev/null | head -5"],
    capture_output=True, text=True, timeout=10
)
log(f"\nBackend /proc/net/tcp: {r.stdout[:500]}")

r = subprocess.run(
    ["docker", "exec", "openclaw-gateway", "sh", "-c",
     "cat /proc/net/tcp 2>/dev/null | head -10"],
    capture_output=True, text=True, timeout=10
)
log(f"Gateway /proc/net/tcp: {r.stdout[:500]}")

log("\n=== DONE ===")
f.close()

