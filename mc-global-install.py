#!/usr/bin/env python3
"""Install mc-api globally as root, test it."""
import subprocess
f = open("/Users/jeffsutherland/clawd/copilot_out.txt", "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

TOKEN = "HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"

# Write mc-api to /usr/local/bin as root with token embedded
mc_api_script = f"""#!/bin/sh
MC_TOKEN="{TOKEN}"
MC_URL="http://host.docker.internal:8001"
case "$1" in
  health) curl -s -m 10 "$MC_URL/health" ;;
  boards) curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/boards" ;;
  cards)  curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/boards/${{2:-agent-security-framework}}/cards" ;;
  update-card) curl -s -m 10 -X PATCH -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/cards/$2" ;;
  create-card) curl -s -m 10 -X POST -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/boards/${{2:-agent-security-framework}}/cards" ;;
  *) M="${{1:-GET}}"; E="$2"; B="$3"
     if [ -n "$B" ]; then curl -s -m 10 -X "$M" -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$B" "$MC_URL$E"
     else curl -s -m 10 -X "$M" -H "Authorization: Bearer $MC_TOKEN" "$MC_URL$E"; fi ;;
esac
"""

# Escape for shell heredoc
r = subprocess.run(
    ["docker", "exec", "-u", "0", "openclaw-gateway", "sh", "-c",
     f"cat > /usr/local/bin/mc-api << 'ENDSCRIPT'\n{mc_api_script}\nENDSCRIPT\nchmod +x /usr/local/bin/mc-api && echo INSTALLED"],
    capture_output=True, text=True, timeout=5
)
log(f"Install: {r.stdout.strip()} {r.stderr.strip()[:100]}")

# Test as node user
r = subprocess.run(
    ["docker", "exec", "-u", "1000", "openclaw-gateway", "mc-api", "health"],
    capture_output=True, text=True, timeout=10
)
log(f"mc-api health: {r.stdout.strip()}")

r = subprocess.run(
    ["docker", "exec", "-u", "1000", "openclaw-gateway", "sh", "-c", "mc-api boards | head -c 150"],
    capture_output=True, text=True, timeout=10
)
log(f"mc-api boards: {r.stdout.strip()[:150]}")

# Verify it's in PATH
r = subprocess.run(
    ["docker", "exec", "-u", "1000", "openclaw-gateway", "which", "mc-api"],
    capture_output=True, text=True, timeout=5
)
log(f"which mc-api: {r.stdout.strip()}")

f.close()

