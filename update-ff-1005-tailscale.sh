#!/bin/bash

# Update FF-1005 with Tailscale architecture improvement
source ~/.jira-config

echo "🔒 Updating FF-1005 with Tailscale Security Enhancement"
echo "===================================================="

# Add comment about Tailscale improvement
TAILSCALE_COMMENT='{
  "body": "🔒 **SECURITY ENHANCEMENT: Tailscale Integration**\n\n**Jeff installed Tailscale on Umbrel + Mac Studio**\n\nThis **significantly improves** the architecture:\n\n**Before (Direct IP):**\n• Exposed Bitcoin RPC ports on public/local network\n• Firewall configuration required\n• Security risk from direct network access\n\n**After (Tailscale Mesh VPN):**\n✅ Encrypted mesh network between services\n✅ No exposed Bitcoin RPC ports\n✅ Zero-config secure networking\n✅ Enterprise-grade WireGuard encryption\n✅ Access control via Tailscale admin panel\n\n**Updated Architecture:**\n```\nBTCPay Server → [Tailscale VPN] → Umbrel Node → Bitcoin Network\n                               └→ Lightning Network\n```\n\n**Updated Information Needed:**\n• Umbrel Tailscale IP address (100.x.x.x format)\n• Bitcoin RPC credentials (same as before)\n• Lightning certificates (same as before)\n• Invite Carlos server to Tailscale network\n\n**Carlos Setup Steps:**\n1. Install Tailscale on BTCPay server\n2. Join Jeff Tailscale network\n3. Use Tailscale IP for Umbrel connection\n4. Deploy BTCPay with secure mesh networking\n\n**Security Benefits:**\n• No port forwarding needed\n• No firewall rules required\n• Encrypted tunnel between all services\n• Audit logs of connections\n• Remote access control\n\n**Documentation Updated:**\n• BTCPAY-TAILSCALE-UPDATE.md created with new architecture\n• Original instructions remain valid with IP substitution\n\n**This is a much better, more secure setup!** 🎯"
}'

echo "Adding Tailscale enhancement comment to FF-1005..."
curl -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$TAILSCALE_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/FF-1005/comment"

echo ""
echo "✅ FF-1005 updated with Tailscale security enhancement"
echo "🔗 Story URL: $JIRA_URL/browse/FF-1005"