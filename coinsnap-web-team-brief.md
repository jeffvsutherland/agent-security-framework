# Coinsnap Fix - Web Team Brief
**URGENT: Customer Payment Processing Down**  
**For: Carlos E. Leaño Suárez & Web Team**  
**Date:** Feb 9, 2026 - 9:55 AM

## 🚨 PROBLEM
- **Coinsnap BROKEN:** Falsely claims Strike.me account down
- **Strike.me CONFIRMED:** Account fully functional, Coinsnap is the issue
- **Customer Impact:** Cannot process Bitcoin/Lightning payments
- **Business Risk:** Lost sales every hour we're down

## 🎯 IMMEDIATE SOLUTIONS (Priority Order)

### **OPTION 1: PayPal Crypto (DO THIS FIRST - Could be live in 2 hours)**
**Carlos Action Items:**
1. **Log into FF PayPal business account**
2. **Check:** Account Settings → Payment Preferences → Look for "Cryptocurrency" 
3. **Update PayPal WordPress plugin** to latest version (2.0+)
4. **Test checkout** - see if crypto options appear
5. **If YES → Deploy immediately**

**Why First:** Already have PayPal infrastructure, fastest path to working payments

### **OPTION 2: BTCPay Server (Primary Long-term Solution)**
**Carlos Action Items:**
1. **Install Plugin:** "BTCPay Server for WooCommerce" 
2. **Create BTCPay instance:** Use hosted service or self-host
3. **Configure Lightning Network** support
4. **Connect to Strike.me** if possible (since we know it works)
5. **Test full payment flow**

**Why This:** Most reliable, no third-party dependency issues

### **OPTION 3: CoinGate (Backup Plan)**
**If above fail:**
1. **Install:** "CoinGate for WooCommerce"
2. **Sign up:** CoinGate merchant account
3. **Configure:** Lightning Network settings
4. **Deploy:** 1% transaction fee but reliable

## ⏰ TIMELINE EXPECTATIONS
- **Option 1 (PayPal):** 1-2 hours if crypto available
- **Option 2 (BTCPay):** 4-6 hours for full setup
- **Option 3 (CoinGate):** 2-3 hours for backup

## 📋 SUCCESS CRITERIA
- ✅ Customers can complete Bitcoin/Lightning payments
- ✅ Payments reach FF account successfully
- ✅ Checkout process is user-friendly  
- ✅ No more Coinsnap dependency

## 🔧 TECHNICAL REQUIREMENTS
All solutions need:
- WordPress/WooCommerce compatibility
- Lightning Network support (fast/cheap transactions)
- Clear customer checkout flow
- Reliable payment confirmation

## 📞 ESCALATION
- **Block on PayPal crypto?** → Call PayPal merchant support
- **BTCPay Server issues?** → Check their documentation/Discord
- **Need backup ASAP?** → Go straight to CoinGate option

## 💰 BUSINESS PRIORITY
**Every hour down = lost revenue**  
**Customer trust impact if payments keep failing**

**CARLOS: Start with PayPal crypto check RIGHT NOW. Report back in 30 minutes.**