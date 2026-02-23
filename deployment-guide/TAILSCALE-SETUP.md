# Tailscale Setup for OpenClaw

## Overview
This guide covers setting up Tailscale for secure, zero-trust networking between OpenClaw components.

## Why Tailscale?
- Encrypted peer-to-peer connections
- No exposed ports to the public internet
- ACL-based access control
- Works behind NAT/firewalls

## Prerequisites
- Tailscale account
- Auth key from Tailscale admin console
- Docker and docker-compose

## Step 1: Generate Auth Key

1. Log in to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
2. Click "Generate auth key"
3. Create reusable key with these tags:
   ```
   tag:openclaw
   ```
4. Copy the key (format: `tskey_XXXX...`)

## Step 2: Store Auth Key Securely

```bash
# Add to .env file
echo 'TAILSCALE_AUTH_KEY=tskey_your_key_here' >> .env
echo 'TAILSCALE_HOSTNAME=openclaw-gateway' >> .env
```

## Step 3: Docker Compose Setup

```yaml
services:
  openclaw-gateway:
    image: openclaw/gateway:latest
    container_name: openclaw-gateway
    volumes:
      - ./state:/home/node/.openclaw
      - /var/run:/var/run
    environment:
      - TAILSCALE_AUTH_KEY=${TAILSCALE_AUTH_KEY}
      - TAILSCALE_HOSTNAME=${TAILSCALE_HOSTNAME:-openclaw-gateway}
    networks:
      - asf-network
    privileged: true
    restart: unless-stopped

  # Tailscale sidecar
  tailscale-gateway:
    image: tailscale/tailscale:latest
    container_name: tailscale-gateway
    environment:
      - TS_AUTH_KEY=${TAILSCALE_AUTH_KEY}
      - TS_HOSTNAME=${TAILSCALE_HOSTNAME:-openclaw-gateway}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_ROUTES=10.0.0.0/8:192.168.0.0/16
    volumes:
      - tailscale-state:/var/lib/tailscale
      - /var/run:/var/run
    network_mode: host
    privileged: true
    restart: unless-stopped
    depends_on:
      - openclaw-gateway

networks:
  asf-network:
    driver: bridge

volumes:
  tailscale-state:
```

## Step 4: Tailscale ACL Configuration

Create `acl-policy.json`:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["tag:openclaw"],
      "dst": ["tag:openclaw:*"]
    },
    {
      "action": "accept",
      "src": ["tag:openclaw"],
      "dst": ["*:*"]
    }
  ],
  "groups": {
    "group:openclaw": ["tag:openclaw"]
  },
  "tagOwners": {
    "tag:openclaw": ["your-email@example.com"]
  }
}
```

Upload ACL:
```bash
tailscale admin acl-set acl-policy.json
```

## Step 5: Update trustedProxies

For OpenClaw to recognize Tailscale IPs as trusted:

```python
# In OpenClaw config
TRUSTED_PROXIES = [
    "100.64.0.0/10",  # Tailscale CGNAT range
    "10.0.0.0/8",     # Tailscale subnet
]
```

Or via environment:
```bash
export OPENCLAW_TRUSTED_PROXIES="100.64.0.0/10,10.0.0.0/8"
```

## Step 6: Verify Connection

```bash
# Check Tailscale status
docker exec tailscale-gateway tailscale status

# Get Tailscale IP
docker exec tailscale-gateway tailscale ip -4

# Test connectivity
docker exec tailscale-gateway ping -c 3 100.x.x.x
```

## Network Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Tailscale Network                        │
│  ┌─────────────────┐      ┌─────────────────┐              │
│  │ OpenClaw GW     │◀────▶│ Mission Control │              │
│  │ 100.64.0.1      │      │ 100.64.0.2      │              │
│  └─────────────────┘      └─────────────────┘              │
│         │                          │                        │
│         ▼                          ▼                        │
│  ┌─────────────────┐      ┌─────────────────┐              │
│  │ Agent Nodes     │◀────▶│ External Services│              │
│  │ 100.64.0.x     │      │ (via exit node)  │              │
│  └─────────────────┘      └─────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

## Security Benefits

| Benefit | Description |
|---------|-------------|
| Encrypted | All traffic between nodes is encrypted |
| Zero Trust | No public exposure of services |
| ACLs | Granular access control policies |
| Audit | All connections logged in Tailscale admin |

## Troubleshooting

### Auth Key Not Working
- Ensure key is reusable (not one-time)
- Check key hasn't expired
- Verify key has required tags

### Containers Can't Reach Each Other
- Check both containers on same Tailscale network
- Verify ACLs allow traffic
- Check `TS_ROUTES` includes your subnet

### trustedProxies Not Working
- Restart gateway after updating config
- Verify IP is in Tailscale range (100.64.0.0/10)
- Check logs for proxy header warnings

---

**Related Documents:**
- [ASF-4 Deployment Guide](./ASF-4-DEPLOYMENT-GUIDE.md)
- [Docker Templates](../docker-templates/)
- [Security Hardening](../docs/asf-5-yara-rules/SECURITY-HARDENING.md)

---
*Last Updated: 2026-02-21*
