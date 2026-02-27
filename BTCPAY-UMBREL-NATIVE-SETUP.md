# BTCPay Server on Umbrel - Native Installation Guide

## 🎉 Much Simpler Architecture!

Jeff is installing BTCPay Server **directly on Umbrel** - this is actually **better** than our separate server approach!

## Architecture Comparison

### **Previous Plan (Complex):**
```
Customer → BTCPay Server (separate server) → Tailscale → Umbrel → Bitcoin Network
```

### **New Plan (Simplified):**
```
Customer → BTCPay Server (on Umbrel) → Bitcoin Network (same machine!)
```

**Benefits:**
✅ **One machine setup** instead of two  
✅ **No networking complexity** (everything local)  
✅ **Umbrel manages everything** (updates, backups, monitoring)  
✅ **Simpler maintenance** for Carlos  

## Strike.me Wallet Integration

**Yes!** You can forward all payments to `drjeffsutherland@strike.me`

### **Option 1: Lightning Address Forwarding (Recommended)**
```
BTCPay receives payment → Automatically forwards → drjeffsutherland@strike.me
```

**Setup in BTCPay:**
1. Go to **Store Settings** → **Lightning**
2. Enable **"Auto-forward payments"**
3. Set **Lightning Address:** `drjeffsutherland@strike.me`
4. Set **Forward threshold:** (e.g., $1 minimum)

### **Option 2: Manual Withdrawal Setup**
```
BTCPay accumulates payments → Manual/scheduled withdrawal → Strike.me
```

## Umbrel BTCPay Configuration

### **During Umbrel Installation:**

1. **Install BTCPay Server App:**
   - Open Umbrel dashboard
   - Go to App Store
   - Install "BTCPay Server"
   - Wait for sync (may take a few hours)

2. **Initial Wallet Setup (When it asks):**
   
   **Choose:** "Connect existing wallet" or "Lightning only"
   
   **For Strike.me integration:**
   - **Don't** create new on-chain wallet on Umbrel
   - **Do** set up Lightning forwarding to Strike.me
   - This keeps everything flowing to your Strike account

3. **Store Configuration:**
   ```
   Store Name: Frequency Foundation
   Default Currency: USD
   Lightning Address: drjeffsutherland@strike.me
   Auto-forward: Enabled
   ```

### **Access BTCPay Admin:**
- **Local access:** `http://umbrel.local/btcpay` 
- **Remote access:** Via Tailscale + Umbrel IP
- **Public access:** Set up domain forwarding (optional)

## Updated FF-1005 Jira Story

This **simplifies Carlos's work significantly:**

### **New Carlos Tasks:**
1. **Domain Setup:** Point `payments.frequencyfoundation.com` → Umbrel BTCPay
2. **SSL Certificate:** Configure for public access (optional)
3. **Website Integration:** Update payment links to Umbrel BTCPay
4. **Webhook Setup:** Point to FF website for order confirmation

### **Removed Tasks:**
- ❌ Separate server deployment
- ❌ Tailscale networking setup  
- ❌ Docker configuration
- ❌ Bitcoin node connection

## Strike.me Lightning Address Benefits

**Automatic Conversion:**
- Customers pay Bitcoin/Lightning
- **Strike automatically converts** to USD
- **Deposits to your Strike account** as USD
- **No crypto handling** for Frequency Foundation books

**Tax Benefits:**
- Strike provides **transaction records**
- **USD accounting** instead of crypto tracking
- **Simpler bookkeeping** for business

## Configuration Recommendations

### **BTCPay Store Settings:**
```
Store Name: Frequency Foundation
Default Currency: USD
Payment Methods: Bitcoin + Lightning Network
Invoice Expiry: 15 minutes
Auto-forward Lightning: drjeffsutherland@strike.me
Forward Threshold: $1.00
Webhook URL: https://frequencyfoundation.com/webhook/btcpay
```

### **For Customer Experience:**
```
Checkout Page: Custom branding with FF logo
Payment Options: Bitcoin, Lightning Network  
Confirmation: Auto-redirect to FF thank you page
Email Receipts: Enabled with FF sender address
```

## Quick Setup Commands (After BTCPay Install)

### **Test Lightning Address:**
```bash
# Verify Strike.me Lightning Address works
curl https://strike.me/.well-known/lnurlp/drjeffsutherland
```

### **Configure Auto-forwarding:**
1. BTCPay Admin → Stores → [Your Store] → Lightning
2. Enable "Automatically forward Lightning payments"  
3. Set Lightning Address: `drjeffsutherland@strike.me`
4. Set minimum amount (e.g., $1)

## Timeline Update

**Reduced from 48 hours to ~6 hours:**
- Umbrel BTCPay installation: 2 hours (mostly waiting for sync)
- Strike.me forwarding setup: 30 minutes
- Domain/SSL configuration: 2 hours
- Website integration: 1.5 hours

## Next Steps

1. **Finish Umbrel BTCPay installation** (you're doing this now)
2. **Configure Strike.me forwarding** (see steps above)  
3. **Test payment flow** (small Lightning payment)
4. **Give Carlos the Umbrel BTCPay URL** for website integration
5. **Set up domain pointing** (if you want public access)

**This is much better than our original plan!** 🎯

One machine, automatic USD conversion, simpler maintenance. Perfect! 

Let me know if you need help with the Strike.me Lightning Address setup or any other configuration steps.