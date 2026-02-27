# BTCPay Server Complete Setup Guide - Updated for Carlos

**Updated:** February 11, 2026  
**Strike Account:** `drjeffsutherlan@strike.me` ✅  
**Status:** BTCPay installed on Umbrel, wallet setup needed

## 📋 Current Situation

### **✅ Completed by Jeff:**
- Umbrel node running with Tailscale
- BTCPay Server installed on Umbrel (native app)
- Store created: "Frequency Foundation" 
- Store ID: `EEdggSfqLM3brZcc36VhZghxAV31ZdoKkG1di45DERBU`
- Lightning node connected (internal)
- Brand color set: `#d2291c`

### **⚠️ Still Needed:**
- Wallet configuration for payouts
- Strike.me auto-forwarding setup
- Website integration by Carlos
- Domain/SSL configuration

## 🎯 Strike.me Integration - Correct Address

**IMPORTANT:** Strike Lightning Address is `drjeffsutherlan@strike.me`
*(Note: "sutherland" is missing the 'd' - this is correct)*

## 📖 Setup Process Jeff Went Through

### **1. BTCPay Initial Installation**
- Installed BTCPay Server from Umbrel App Store
- Skipped wallet connection during initial setup
- Configured store: "Frequency Foundation"
- Connected to internal Lightning node

### **2. Current BTCPay Configuration**
Jeff's BTCPay dashboard shows:
```
Dashboard Settings Rates Checkout Appearance Access Tokens Users Roles 
Webhooks Payout Processors Emails Forms Wallets Bitcoin Lightning 
Payments Invoices Reporting Requests Pull Payments Payouts Plugins 
Crowdfund Pay Button Point of Sale Shopify Subscriptions Lightning 
Address Manage Plugins Server Settings Account
```

### **3. Lightning Configuration Status**
- **Lightning node:** Connected (internal)
- **Wallet balances:** Visible
- **Channel management:** Available
- **Lightning Address section:** Available but not configured

### **4. Wallet Configuration Needed**
When Jeff checked Payout Processors:
- "You haven't configured wallet yet" message appeared
- **Action needed:** Set up Bitcoin wallet to enable payouts

## 🔧 Next Steps for Jeff (Before Carlos Takes Over)

### **Step 1: Configure Bitcoin Wallet**
```
BTCPay Dashboard → Wallets → Bitcoin → Set up a wallet
Choose: "Generate new wallet" → "Hot wallet"
Save seed phrase securely
```

### **Step 2: Configure Payout Processor**
After wallet is set up:
```
BTCPay Dashboard → Payout Processors
Add new processor → Lightning/Bitcoin payout
Configure auto-payout to: drjeffsutherlan@strike.me
Set threshold: $1.00 (minimum before payout)
```

### **Step 3: Test Payment Flow**
```
Create test invoice → Pay with Lightning → Verify auto-forward to Strike
Check Strike account for USD conversion
```

## 🌐 Carlos Tasks - Website Integration

### **Current BTCPay Server Access**
- **Local URL:** `http://umbrel.local/btcpay`
- **Tailscale access:** Available via Jeff's Tailscale network
- **Store ID:** `EEdggSfqLM3brZcc36VhZghxAV31ZdoKkG1di45DERBU`

### **1. Domain Configuration**
**Options for public access:**
- `payments.frequencyfoundation.com`
- `btc.frequencyfoundation.com` 
- `checkout.frequencyfoundation.com`

**Setup process:**
1. DNS: Point chosen domain to Jeff's external IP or Tailscale
2. SSL: Configure Let's Encrypt or existing certificate
3. Reverse proxy: Route domain to `umbrel.local:3003/btcpay`

### **2. Payment Integration**

**BTCPay API Integration:**
```javascript
// Create invoice via BTCPay API
const invoice = await fetch(`${btcpayUrl}/api/v1/stores/${storeId}/invoices`, {
  method: 'POST',
  headers: {
    'Authorization': `token ${apiKey}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    amount: orderTotal,
    currency: 'USD',
    checkout: {
      redirectURL: 'https://frequencyfoundation.com/payment-success'
    }
  })
});
```

**BTCPay Server Details:**
- **Store ID:** `EEdggSfqLM3brZcc36VhZghxAV31ZdoKkG1di45DERBU`
- **API Token:** Generate in BTCPay → Access Tokens
- **Webhook URL:** `https://frequencyfoundation.com/webhook/btcpay`

### **3. Checkout Integration**

**Replace Coinsnap buttons with:**
```html
<!-- BTCPay Server Payment Button -->
<form method="POST" action="https://your-btcpay-domain/api/v1/invoices">
  <input type="hidden" name="storeId" value="EEdggSfqLM3brZcc36VhZghxAV31ZdoKkG1di45DERBU">
  <input type="hidden" name="amount" value="[ORDER_TOTAL]">
  <input type="hidden" name="currency" value="USD">
  <input type="submit" value="Pay with Bitcoin">
</form>
```

**Or use BTCPay's Pay Button generator:**
- BTCPay Dashboard → Pay Button → Configure → Generate code

### **4. Webhook Configuration**

**Set up webhook endpoint:**
```php
// webhook/btcpay.php
$payload = file_get_contents('php://input');
$event = json_decode($payload, true);

if ($event['type'] === 'InvoiceSettled') {
    // Payment confirmed
    $orderId = $event['data']['orderId'];
    // Update order status, send confirmation email
}
```

**Webhook URL in BTCPay:**
```
BTCPay → Store Settings → Webhooks → Add Webhook
URL: https://frequencyfoundation.com/webhook/btcpay
Events: InvoiceSettled, InvoiceExpired
```

## 🏗️ Architecture Overview

### **Final Payment Flow:**
```
Customer → Frequency Foundation Website → BTCPay Server (Umbrel) 
→ Auto-payout → drjeffsutherlan@strike.me → USD in Strike account
```

### **Technical Stack:**
- **Bitcoin Node:** Umbrel (local)
- **Lightning Node:** Umbrel LND (local)
- **Payment Processor:** BTCPay Server (Umbrel app)
- **Auto-conversion:** Strike.me Lightning Address
- **Website:** Frequency Foundation (Carlos integration)

## ⚡ Simplified Timeline

### **Jeff's Remaining Tasks (1 hour):**
1. Set up Bitcoin wallet in BTCPay (15 minutes)
2. Configure Strike.me payout processor (15 minutes)
3. Test payment flow (15 minutes)
4. Generate API tokens for Carlos (15 minutes)

### **Carlos Tasks (4 hours):**
1. Domain and SSL setup (2 hours)
2. Website payment integration (1.5 hours)
3. Webhook configuration (30 minutes)

### **Total Deployment:** ~5 hours (down from original 48 hours)

## 🎯 Success Metrics

### **Technical Success:**
- BTCPay invoices generate successfully
- Lightning payments process in <5 seconds
- Auto-forward to Strike.me working
- USD conversion appears in Strike account
- Website integration seamless

### **Business Success:**
- Customer payments restored immediately
- Zero ongoing transaction fees
- Simplified USD bookkeeping
- No KYC requirements for customers

## 📞 Support Information

### **For Carlos Questions:**
- **BTCPay Documentation:** https://docs.btcpayserver.org/
- **API Documentation:** https://docs.btcpayserver.org/API/
- **Strike Documentation:** https://docs.strike.me/

### **Configuration Files Location:**
- **BTCPay:** Running as Umbrel app
- **Access:** Via Tailscale network or local umbrel.local
- **Logs:** Available in Umbrel app management

## 🔑 Critical Information for Carlos

### **BTCPay Access:**
- **Admin URL:** `http://umbrel.local/btcpay` (on Jeff's network)
- **Store ID:** `EEdggSfqLM3brZcc36VhZghxAV31ZdoKkG1di45DERBU`
- **Strike Address:** `drjeffsutherlan@strike.me`

### **Next Steps:**
1. **Jeff completes:** Wallet + payout processor setup
2. **Jeff provides:** API tokens and public access URL
3. **Carlos implements:** Website integration
4. **Test together:** Full payment flow
5. **Go live:** Replace Coinsnap completely

**This replaces the broken Coinsnap system and restores FF customer payments with automatic USD conversion!** 🎯

---
**Updated:** 2026-02-11 14:03 EST  
**Status:** Ready for final Jeff setup, then Carlos integration