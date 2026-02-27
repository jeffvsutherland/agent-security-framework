#!/bin/bash

# Update FF-1005 with current status and corrected Strike address
source ~/.jira-config

echo "📋 Updating FF-1005 with Final Status and Corrected Strike Address"
echo "================================================================="

# Add comment with current status
FINAL_STATUS_COMMENT='{
  "body": "📋 **CURRENT STATUS UPDATE - Ready for Final Steps**\n\n**✅ Jeff Completed:**\n• BTCPay Server installed on Umbrel (native app)\n• Store configured: \"Frequency Foundation\"\n• Store ID: EEdggSfqLM3brZcc36VhZghxAV31ZdoKkG1di45DERBU\n• Lightning node connected (internal)\n• Tailscale network configured\n• Brand color set (#d2291c)\n\n**🔧 Strike.me Integration - CORRECTED ADDRESS:**\n• **Correct Strike Lightning Address:** `drjeffsutherlan@strike.me`\n• *(Note: Missing \"d\" in sutherland - this is correct)*\n\n**⚠️ Jeff Still Needs To Complete:**\n1. **Set up Bitcoin wallet** (BTCPay → Wallets → Bitcoin → Generate new wallet)\n2. **Configure payout processor** (BTCPay → Payout Processors → Add Strike forwarding)\n3. **Test payment flow** (Create invoice → Pay → Verify Strike forwarding)\n4. **Generate API tokens** for Carlos integration\n\n**📋 Carlos Tasks Ready:**\n1. **Domain configuration** (payments.frequencyfoundation.com)\n2. **Website integration** (Replace Coinsnap with BTCPay)\n3. **Webhook setup** for order confirmations\n4. **SSL certificate** configuration\n\n**📚 Documentation Updated:**\n• BTCPAY-CARLOS-COMPLETE-GUIDE.md (7,406 bytes)\n• Complete setup process documented\n• All conversation details incorporated\n• Correct Strike address throughout\n\n**⏰ Updated Timeline:**\n• **Jeff remaining tasks:** 1 hour\n• **Carlos integration:** 4 hours\n• **Total deployment:** ~5 hours (massive reduction from original 48 hours)\n\n**🎯 Payment Flow:**\n```\nCustomer → FF Website → BTCPay (Umbrel) → Auto-payout → drjeffsutherlan@strike.me → USD in Strike\n```\n\n**🚀 Next Actions:**\n1. Jeff completes wallet + payout processor setup\n2. Jeff provides Carlos with API tokens and access details\n3. Carlos implements website integration\n4. Test full payment flow together\n5. Go live and replace Coinsnap completely\n\n**Business Impact:**\n• Restore customer payments immediately\n• Eliminate transaction processing fees\n• Automatic USD conversion via Strike\n• Simplified bookkeeping (USD vs crypto)\n\n**This solution directly addresses the revenue-impacting Coinsnap failure and provides a more robust, fee-free payment system!** 🎯"
}'

echo "Adding final status update to FF-1005..."
curl -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$FINAL_STATUS_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/FF-1005/comment"

echo ""
echo "✅ FF-1005 updated with final status and corrected Strike address"
echo "📋 Documentation ready for Carlos"
echo "🔗 Story URL: $JIRA_URL/browse/FF-1005"