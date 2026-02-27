# How to Connect BTCPay Server to Strike.me

## 🎯 You Don't "Connect" - You Configure Auto-Forwarding

**Strike.me integration works through Lightning Address forwarding, not wallet connection.**

## Step-by-Step Process

### **1. In BTCPay Wallet Connection Screen:**

**Choose one of these options:**
- **"Skip wallet setup"** ✅ (Recommended)
- **"Lightning only"** ✅ (If available)
- **"Configure later"** ✅

**DON'T choose:**
- ❌ "Connect existing wallet"
- ❌ "Import wallet"
- ❌ "Hardware wallet"

### **2. Complete BTCPay Initial Setup:**

```
Store Name: Frequency Foundation
Default Currency: USD
Admin Password: [Create strong password]
```

### **3. After BTCPay Loads - Configure Lightning:**

**Go to:** BTCPay Dashboard → **Stores** → **[Your Store Name]** → **Lightning**

**Enable Lightning Network:**
- Toggle: **"Enable Lightning Network"** = ON
- Connection: Should automatically connect to Umbrel's Lightning node

### **4. Configure Strike Auto-Forwarding:**

**In Lightning Settings:**
- **Auto-forward payments:** Enable ✅
- **Lightning Address:** `drjeffsutherland@strike.me`
- **Forward threshold:** `$1.00` (minimum amount before forwarding)
- **Forward immediately:** Enable ✅

### **5. Test the Connection:**

**Create test invoice:**
1. Go to **Invoices** → **Create Invoice**
2. Amount: $5.00
3. Description: "Test Strike forwarding"
4. **Create Invoice**

**Pay with Lightning wallet:**
- Use any Lightning wallet to pay the test invoice
- Should auto-forward to your Strike account within seconds

## Alternative Setup (If Auto-Forward Not Available)

### **Manual Lightning Address Setup:**

If BTCPay doesn't have auto-forward option:

1. **Create invoices normally** in BTCPay
2. **Manually withdraw** accumulated Lightning balance
3. **Send to:** `drjeffsutherland@strike.me`
4. **Set up scheduled withdrawals** (daily/weekly)

## Strike.me Lightning Address Verification

### **Test Your Lightning Address:**

```bash
# Verify Strike Lightning address works
curl https://strike.me/.well-known/lnurlp/drjeffsutherland

# Should return JSON with Strike payment info
```

**Or test with any Lightning wallet:**
- Send small amount to: `drjeffsutherland@strike.me`
- Verify it arrives in your Strike account

## BTCPay Configuration Summary

### **What You're Setting Up:**

```
Payment Flow:
Customer Lightning Payment → BTCPay Receives → Auto-forwards → Strike.me → USD in your account
```

### **Key Settings:**
- **Store:** Frequency Foundation
- **Primary Payment:** Lightning Network
- **Auto-forward:** drjeffsutherland@strike.me
- **Currency:** USD (for customer-facing prices)
- **Threshold:** $1.00 (minimum to forward)

## Next Steps After Setup

### **1. Test Payment Flow:**
- Create test invoice
- Pay with Lightning wallet
- Verify USD appears in Strike account

### **2. Configure Website:**
- Give Carlos your BTCPay URL
- Carlos updates payment buttons
- Carlos sets up webhooks for order confirmations

### **3. Go Live:**
- Update FF website payment options
- Monitor first real customer payments
- Verify Strike integration working

## Quick Answer

**Right now in BTCPay setup:**
1. **Choose:** "Skip wallet setup" or "Lightning only"
2. **Complete:** Store configuration
3. **Then:** Configure Lightning auto-forwarding to drjeffsutherland@strike.me

**You'll configure Strike forwarding AFTER BTCPay basic setup is complete.**

What options do you see in the current BTCPay screen?