# 📊 Stock & Crypto Price Checker Guide for OpenClaw Agents

**Quick Reference for All Agents**

---

## 🎯 What You Can Check

### Stocks
- **US Stocks:** AAPL, TSLA, NVDA, MSFT, GOOGL, AMZN, META, etc.
- **Indices:** SPY (S&P 500), QQQ (Nasdaq), DIA (Dow Jones)
- **International:** Add country code (e.g., SONY.JP)

### Cryptocurrencies ⭐ Recommended
- **Major:** BTC (Bitcoin), ETH (Ethereum), SOL (Solana)
- **Alt Coins:** ADA, DOGE, XRP, DOT, MATIC, AVAX, LINK, UNI
- **Stablecoins:** USDT, USDC

---

## 🚀 Quick Commands

### For Bitcoin (Most Common)
```bash
python3 /workspace/skills/stock-price/crypto_price.py btc
```

### For Ethereum
```bash
python3 /workspace/skills/stock-price/crypto_price.py eth
```

### For Apple Stock
```bash
python3 /workspace/skills/stock-price/stock_price.py AAPL
```

---

## 📖 Full Usage Guide

### Cryptocurrency Prices (Recommended - Better API)

**Single Crypto:**
```bash
cd /workspace/skills/stock-price
python3 crypto_price.py bitcoin
```

**Short Symbols Work Too:**
```bash
python3 crypto_price.py btc
python3 crypto_price.py eth
python3 crypto_price.py sol
```

**Output Example:**
```
₿ BITCOIN (Bitcoin)
Price: $66,160.00
24h Change: -2.15% 📉
24h Volume: $44.09B
Market Cap: $1.32T
```

**Supported Symbols:**
- btc, bitcoin
- eth, ethereum
- sol, solana
- ada, cardano
- doge, dogecoin
- xrp, ripple
- dot, polkadot
- matic, polygon
- avax, avalanche
- link, chainlink
- uni, uniswap

### Stock Prices

**Single Stock:**
```bash
cd /workspace/skills/stock-price
python3 stock_price.py AAPL
```

**Multiple Stocks:**
```bash
python3 stock_price.py AAPL TSLA NVDA
```

**Note:** Stock API has rate limits. If you get HTTP 429 error, wait 60 seconds.

**Output Example:**
```
📈 AAPL - Apple Inc.
Price: USD $237.45
Change: +$2.85 (+1.21%)
Previous Close: $234.60
Volume: 48,234,567
Market Cap: $3.65T
52-Week Range: $164.08 - $237.82
```

---

## 🤖 Agent-Specific Instructions

### For Raven (Product Owner)

**From Telegram/Mission Control:**
You can check prices directly using bash commands in your workflow.

**Example Tasks:**
1. Check BTC price before standup:
   ```bash
   python3 /workspace/skills/stock-price/crypto_price.py btc
   ```

2. Portfolio snapshot:
   ```bash
   python3 /workspace/skills/stock-price/crypto_price.py btc
   python3 /workspace/skills/stock-price/crypto_price.py eth
   ```

3. Tech stocks check:
   ```bash
   python3 /workspace/skills/stock-price/stock_price.py AAPL
   python3 /workspace/skills/stock-price/stock_price.py TSLA
   ```

### For Research Agent

**Market Research:**
```bash
# Gather data for reports
python3 /workspace/skills/stock-price/crypto_price.py btc > /workspace/reports/btc-price.txt
```

### For Sales Agent

**Quick Price References:**
```bash
# For customer discussions
python3 /workspace/skills/stock-price/crypto_price.py btc
```

### For Social Agent

**Content Creation:**
```bash
# Get latest prices for social posts
python3 /workspace/skills/stock-price/crypto_price.py btc eth sol
```

---

## 🐳 Docker Container Usage

**From Host Machine:**
```bash
# Bitcoin
docker exec openclaw-gateway python3 /workspace/skills/stock-price/crypto_price.py btc

# Apple Stock
docker exec openclaw-gateway python3 /workspace/skills/stock-price/stock_price.py AAPL
```

**Inside Container:**
```bash
# If you're already inside the container
python3 /workspace/skills/stock-price/crypto_price.py btc
```

---

## ⚙️ Technical Details

### File Locations

**Host (Mac):**
- `/Users/jeffsutherland/clawd/skills/stock-price/`

**Docker Container:**
- `/workspace/skills/stock-price/`
- Mounted from `~/clawd` workspace

**Files:**
- `crypto_price.py` - Cryptocurrency prices (CoinGecko API)
- `stock_price.py` - Stock prices (Yahoo Finance API)
- `skill.sh` - Bash wrapper
- `README.md` - Full documentation

### APIs Used

**Cryptocurrency (crypto_price.py):**
- API: CoinGecko (free, no key required)
- Rate Limits: ~10-50 requests/minute
- Best for: BTC, ETH, and all major cryptos

**Stocks (stock_price.py):**
- API: Yahoo Finance (free, no key required)
- Rate Limits: Lower (wait 60s if rate-limited)
- Best for: US stocks, ETFs, indices

---

## 🔧 Troubleshooting

### HTTP 429 Error (Rate Limited)
**Solution:** Wait 60 seconds before next request

```bash
# Check one at a time with delays
python3 crypto_price.py btc
sleep 5
python3 crypto_price.py eth
```

### Symbol Not Found
**Crypto:** Use full name or check supported list:
```bash
python3 crypto_price.py  # Shows help with supported symbols
```

**Stocks:** Verify ticker symbol on Yahoo Finance or Google

### Permission Denied
**Fix:** Make scripts executable:
```bash
chmod +x /workspace/skills/stock-price/*.py
```

---

## 💡 Common Use Cases

### Morning Standup - Portfolio Check
```bash
#!/bin/bash
echo "=== Morning Portfolio Check ==="
python3 /workspace/skills/stock-price/crypto_price.py btc
sleep 2
python3 /workspace/skills/stock-price/crypto_price.py eth
sleep 2
python3 /workspace/skills/stock-price/stock_price.py AAPL
```

### Customer Demo - Live Prices
```bash
# Show real-time data during demo
python3 /workspace/skills/stock-price/crypto_price.py bitcoin ethereum solana
```

### Report Generation
```bash
# Save to file for reports
python3 /workspace/skills/stock-price/crypto_price.py btc > /workspace/reports/btc-$(date +%Y%m%d).txt
```

---

## 🔒 Security Notes

- ✅ No API keys required
- ✅ No authentication needed
- ✅ Read-only operations
- ✅ No financial transactions
- ✅ Public data only

**Rate Limit Compliance:**
- Wait 2-5 seconds between requests
- Don't hammer the APIs
- Use crypto_price.py for better limits

---

## 📞 Questions?

**For Raven:** If you need other data sources or different symbols, ask Jeff to extend the skills.

**For All Agents:** This skill works from inside Docker containers. The `/workspace` mount gives you access to all scripts in `~/clawd`.

---

**Last Updated:** February 23, 2026
**Version:** 1.0
**Tested On:** OpenClaw 2026.2.19, Mission Control Latest

---

## Quick Reference Card

```
┌─────────────────────────────────────────────┐
│  🔥 MOST COMMON COMMANDS                    │
├─────────────────────────────────────────────┤
│  Bitcoin:                                   │
│  python3 /workspace/skills/stock-price/\    │
│          crypto_price.py btc                │
│                                             │
│  Ethereum:                                  │
│  python3 /workspace/skills/stock-price/\    │
│          crypto_price.py eth                │
│                                             │
│  Apple Stock:                               │
│  python3 /workspace/skills/stock-price/\    │
│          stock_price.py AAPL                │
│                                             │
│  From Host:                                 │
│  docker exec openclaw-gateway \             │
│    python3 /workspace/skills/stock-price/\  │
│    crypto_price.py btc                      │
└─────────────────────────────────────────────┘
```

---

**🦞 Happy Trading! (Informational Purposes Only)**
