# Stock & Crypto Price Checker Skills

Get real-time prices for stocks and cryptocurrencies.

## Usage for Raven (Product Owner Agent)

**From Telegram/Chat:**
Ask Raven: "What's the stock price for AAPL?" or "Check price for TSLA"

**Direct Command:**
```bash
cd /workspace/skills/stock-price
python3 stock_price.py AAPL
```

**Multiple Stocks:**
```bash
python3 stock_price.py AAPL TSLA NVDA MSFT
```

## How Raven Can Use This

1. **From Docker Container:**
   ```bash
   docker exec openclaw-gateway python3 /workspace/skills/stock-price/stock_price.py AAPL
   ```

2. **Via Bash Skill:**
   Raven can use her bash/shell access to run:
   ```bash
   python3 ~/clawd/skills/stock-price/stock_price.py AAPL
   ```

## Examples

### Stocks
```bash
# Single stock
python3 stock_price.py AAPL

# Multiple stocks (may hit rate limits)
python3 stock_price.py AAPL TSLA NVDA
```

### Cryptocurrencies (Recommended - Better Rate Limits)
```bash
# Bitcoin
python3 crypto_price.py bitcoin
# or use short symbol
python3 crypto_price.py btc

# Ethereum
python3 crypto_price.py eth

# Multiple cryptos (check one at a time to avoid rate limits)
python3 crypto_price.py btc
python3 crypto_price.py eth
python3 crypto_price.py sol

# Supported: btc, eth, sol, ada, doge, xrp, dot, matic, avax, link, uni
```

## Output Format

```
📈 AAPL - Apple Inc.
Price: USD $237.45
Change: +$2.85 (+1.21%)
Previous Close: $234.60
Volume: 48,234,567
Market Cap: $3.65T
52-Week Range: $164.08 - $237.82
```

## API Used

Uses Yahoo Finance free API - no authentication required, no rate limits for reasonable use.

## Fallback if Rate Limited

If you get rate limited, wait 60 seconds or use the alternative yfinance library:

```bash
pip install yfinance
python3 -c "import yfinance as yf; print(yf.Ticker('AAPL').info['regularMarketPrice'])"
```
