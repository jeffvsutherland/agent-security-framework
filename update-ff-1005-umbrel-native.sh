#!/bin/bash

# Update FF-1005 with simplified Umbrel native BTCPay approach
source ~/.jira-config

echo "🎉 Updating FF-1005 with Simplified Umbrel Native Architecture"
echo "============================================================"

# Add comment about simplified architecture
UMBREL_NATIVE_COMMENT='{
  "body": "🎉 **MAJOR SIMPLIFICATION: BTCPay Server Native on Umbrel**\n\n**Jeff is installing BTCPay Server directly on Umbrel** - this is much better than our separate server approach!\n\n**Architecture Comparison:**\n\n**Previous (Complex):**\n```\nCustomer → BTCPay Server (separate server) → Tailscale → Umbrel → Bitcoin\n```\n\n**New (Simplified):**\n```\nCustomer → BTCPay Server (on Umbrel) → Bitcoin Network (same machine!)\n```\n\n**Benefits:**\n✅ One machine setup instead of two\n✅ No networking complexity (everything local)\n✅ Umbrel manages everything (updates, backups, monitoring)\n✅ Simpler maintenance for Carlos\n✅ Reduced deployment time: 48 hours → 6 hours\n\n**Strike.me Integration:**\n✅ Auto-forward payments to drjeffsutherland@strike.me\n✅ Automatic USD conversion via Strike\n✅ Simplified bookkeeping (USD instead of crypto tracking)\n✅ Strike provides transaction records for taxes\n\n**Updated Carlos Tasks:**\n1. ✅ **Removed:** Separate server deployment\n2. ✅ **Removed:** Tailscale networking setup\n3. ✅ **Removed:** Docker configuration\n4. ✅ **Removed:** Bitcoin node connection\n5. **New:** Domain setup (point to Umbrel BTCPay)\n6. **New:** Website integration (update payment links)\n7. **New:** Webhook configuration for order confirmations\n\n**Configuration:**\n```\nStore Name: Frequency Foundation\nPayment Methods: Bitcoin + Lightning Network\nAuto-forward: drjeffsutherland@strike.me\nWebhook: https://frequencyfoundation.com/webhook/btcpay\n```\n\n**Timeline Update:**\n• Umbrel BTCPay installation: 2 hours (mostly sync waiting)\n• Strike.me forwarding setup: 30 minutes\n• Domain/SSL configuration: 2 hours\n• Website integration: 1.5 hours\n• **Total: ~6 hours** (down from 48 hours)\n\n**Next Steps:**\n1. Jeff completes Umbrel BTCPay installation\n2. Jeff configures Strike.me auto-forwarding\n3. Jeff tests payment flow\n4. Jeff provides Carlos with Umbrel BTCPay URL\n5. Carlos handles website integration\n\n**Documentation Updated:**\n• BTCPAY-UMBREL-NATIVE-SETUP.md created\n• Simplified deployment guide\n• Strike.me Lightning Address integration steps\n\n**This is much simpler and better!** 🚀"
}'

echo "Adding Umbrel native architecture comment to FF-1005..."
curl -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$UMBREL_NATIVE_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/FF-1005/comment"

echo ""
echo "✅ FF-1005 updated with simplified Umbrel native architecture"
echo "⏰ Timeline reduced from 48 hours to ~6 hours"
echo "🔗 Story URL: $JIRA_URL/browse/FF-1005"