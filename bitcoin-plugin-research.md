# Coinsnap Replacement Research
**URGENT:** Frequency Foundation Bitcoin/Lightning Payment Solution

## Current Situation
- **Problem:** Coinsnap broken, falsely claims Strike.me account is down
- **Confirmed:** Strike.me account is fully functional (per Strike support)
- **Impact:** Blocking customer Bitcoin/Lightning payments
- **Platform:** WordPress site needs working Bitcoin plugin

## Immediate WordPress Plugin Options

### 1. BTCPay Server WordPress Plugin ⭐ **RECOMMENDED**
- **Plugin:** BTCPay Server for WooCommerce
- **Pros:** 
  - Self-hosted, no third-party dependencies
  - Lightning Network support
  - Strike.me integration possible
  - Open source, highly reliable
  - Used by major Bitcoin companies
- **Setup:** Requires BTCPay Server instance (can use hosted services)
- **Cost:** Free plugin + hosting costs

### 2. Strike API Direct Integration
- **Approach:** Custom WordPress plugin using Strike's API
- **Pros:** 
  - Direct connection to your working Strike account
  - Bypass all third-party processors
  - Full control over transaction flow
- **Requirements:** Custom development work
- **Timeline:** 1-2 weeks development

### 3. PayPal Crypto Integration ⭐ **EMERGING OPTION**
- **Status:** PayPal rolling out crypto payments 2024-2026
- **Advantage:** Leverages existing PayPal plugin infrastructure
- **Timeline:** Check current availability for merchants
- **Pros:** Familiar integration, trusted by customers

### 4. CoinGate WordPress Plugin
- **Plugin:** CoinGate for WooCommerce
- **Pros:** 
  - Established processor
  - Lightning Network support
  - Multiple cryptocurrency support
- **Fees:** ~1% transaction fee
- **Setup:** Quick WordPress integration

### 5. OpenNode WordPress Plugin
- **Plugin:** OpenNode for WooCommerce  
- **Pros:**
  - Lightning Network focused
  - Good API documentation
  - Enterprise features
- **Fees:** 1% transaction fee
- **Setup:** Straightforward integration

## PayPal Crypto Status Check
**Action Items:**
1. Check PayPal business account for crypto payment options
2. Verify if current PayPal plugin supports crypto transactions
3. Contact PayPal merchant support about crypto availability

## Immediate Recommendations

### **Quick Fix (This Week):**
1. **BTCPay Server** - Most reliable long-term solution
2. **CoinGate** - Fastest setup if you need something TODAY

### **Strategic Fix (Next 2 weeks):**
1. **Strike API integration** - Custom plugin connecting directly to your working Strike account
2. **PayPal crypto upgrade** - If available for your account

## Next Steps
1. **Priority 1:** Install BTCPay Server or CoinGate plugin today
2. **Priority 2:** Research PayPal crypto availability 
3. **Priority 3:** Plan Strike API direct integration
4. **Priority 4:** Update TYD-3659 with findings and assign to Carlos

## Technical Requirements
- WordPress/WooCommerce compatible
- Lightning Network support (for fast, cheap transactions)
- API integration capability
- Customer checkout flow that doesn't confuse non-crypto users

**CRITICAL:** Need working solution within 24-48 hours to prevent lost sales.