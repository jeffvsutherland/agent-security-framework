# BTCPay Server Wallet Connection - Strike.me Integration

## 🚨 Don't Connect Strike Extended Public Key!

**Jeff asked:** "Do I add extended public key I get from Strike?"

**Answer: NO** - That won't achieve the auto-forwarding to drjeffsutherland@strike.me

## Recommended Approach: Lightning-Only Setup

### **Option 1: Skip Wallet Connection (Recommended)**

**When BTCPay asks "Connect to existing wallet":**

1. **Choose:** "Skip" or "Configure later"
2. **Why:** We want Lightning-only payments with auto-forwarding
3. **Result:** BTCPay won't have an on-chain wallet, just Lightning

### **Then Configure Lightning Auto-Forwarding:**

1. **Go to:** BTCPay Admin → Stores → [Your Store] → Lightning
2. **Enable:** "Lightning Network"  
3. **Configure:** Auto-forward settings
4. **Set Lightning Address:** `drjeffsutherland@strike.me`
5. **Test:** Small Lightning payment

## Alternative: Hot Wallet + Forwarding

### **Option 2: Let BTCPay Create Wallet**

**If BTCPay insists on wallet connection:**

1. **Choose:** "Create new wallet" or "Generate new wallet"
2. **Let BTCPay:** Create its own hot wallet on Umbrel
3. **Then configure:** Auto-forwarding to Strike.me for both:
   - Lightning payments → drjeffsutherland@strike.me
   - Bitcoin payments → withdraw to Strike periodically

## Why NOT Use Strike Extended Public Key

### **Problems with Strike Extended Public Key:**

❌ **Strike doesn't provide** extended public keys for Lightning addresses  
❌ **Won't enable auto-forwarding** - just creates watch-only monitoring  
❌ **Adds complexity** without achieving the goal  
❌ **Strike Lightning Address** ≠ Bitcoin wallet extended public key  

### **What Strike Provides:**
- **Lightning Address:** drjeffsutherland@strike.me ✅ (use this)
- **Invoice generation:** For receiving payments ✅
- **Extended public keys:** Not typically provided ❌

## Step-by-Step Setup

### **1. Wallet Connection Screen:**
```
BTCPay: "Connect to existing wallet?"
You: [Skip] or [Configure Later]
```

### **2. Store Configuration:**
```
Store Name: Frequency Foundation
Default Currency: USD
Primary Payment: Lightning Network
```

### **3. Lightning Configuration:**
```
Lightning Network: Enabled
Auto-forward: Enabled  
Forward Address: drjeffsutherland@strike.me
Forward Threshold: $1.00
```

### **4. Test Setup:**
```
Create test invoice → Pay with Lightning → Verify forwarding to Strike
```

## Payment Flow

### **Customer Experience:**
```
1. Customer clicks "Pay with Bitcoin"
2. BTCPay shows Lightning invoice QR code
3. Customer scans with Lightning wallet
4. Payment instantly forwarded to Strike.me
5. Strike converts to USD in your account
```

### **Your Experience:**
```
1. BTCPay receives Lightning payment
2. Automatically forwards to drjeffsutherland@strike.me  
3. Strike converts BTC/Lightning → USD
4. USD appears in your Strike account
5. Strike sends you notification
```

## Configuration Priority

### **Essential Settings:**
1. ✅ **Store configured** (Frequency Foundation)
2. ✅ **Lightning enabled** (primary payment method)
3. ✅ **Auto-forward to Strike.me** (drjeffsutherland@strike.me)
4. ✅ **Test payment** (verify forwarding works)

### **Optional Settings:**
- On-chain Bitcoin wallet (if you want both Lightning + Bitcoin)
- Custom checkout page branding
- Webhook integration with FF website
- Email notifications

## Quick Answer

**When BTCPay asks about wallet connection:**

**Choose: "Skip" or "Lightning only"**

**Then focus on:** Lightning Network setup with Strike.me auto-forwarding

**This achieves your goal:** All payments → Strike.me → USD conversion → Your Strike account

**Much simpler than:** Wallet management + manual forwarding

Let me know what BTCPay shows you after you skip the wallet connection step!