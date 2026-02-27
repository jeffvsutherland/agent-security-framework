#!/bin/bash
# Stock Price Checker Skill
# Usage: stock-price <SYMBOL>
# Example: stock-price AAPL

set -e

SYMBOL="${1:-}"

if [ -z "$SYMBOL" ]; then
    echo "Usage: stock-price <SYMBOL>"
    echo "Example: stock-price AAPL"
    exit 1
fi

# Use Yahoo Finance API (free, no key required)
URL="https://query1.finance.yahoo.com/v8/finance/chart/${SYMBOL}?interval=1d&range=1d"

# Fetch and parse the data
RESPONSE=$(curl -s "$URL")

# Extract key data using jq (if available) or basic parsing
if command -v jq >/dev/null 2>&1; then
    # Use jq for clean parsing
    PRICE=$(echo "$RESPONSE" | jq -r '.chart.result[0].meta.regularMarketPrice // "N/A"')
    PREV_CLOSE=$(echo "$RESPONSE" | jq -r '.chart.result[0].meta.previousClose // "N/A"')
    CURRENCY=$(echo "$RESPONSE" | jq -r '.chart.result[0].meta.currency // "USD"')
    NAME=$(echo "$RESPONSE" | jq -r '.chart.result[0].meta.longName // .chart.result[0].meta.symbol // "N/A"')

    if [ "$PRICE" != "N/A" ] && [ "$PREV_CLOSE" != "N/A" ]; then
        CHANGE=$(echo "$PRICE - $PREV_CLOSE" | bc 2>/dev/null || echo "N/A")
        CHANGE_PCT=$(echo "scale=2; ($PRICE - $PREV_CLOSE) / $PREV_CLOSE * 100" | bc 2>/dev/null || echo "N/A")

        echo "📈 $SYMBOL - $NAME"
        echo "Price: $CURRENCY $PRICE"
        echo "Previous Close: $CURRENCY $PREV_CLOSE"
        echo "Change: $CHANGE ($CHANGE_PCT%)"
    else
        echo "❌ Could not retrieve price for $SYMBOL"
        echo "Symbol may be invalid or market data unavailable"
    fi
else
    # Fallback: basic grep parsing
    echo "$RESPONSE" | grep -o '"regularMarketPrice":[0-9.]*' | head -1 | sed 's/"regularMarketPrice":/Price: $/'
fi
