#!/usr/bin/env python3
"""
Stock Price Checker Skill
Fetches real-time stock prices using Yahoo Finance API (free, no key required)

Usage:
    python3 stock_price.py AAPL
    python3 stock_price.py TSLA NVDA MSFT
"""

import sys
import json
import urllib.request
import urllib.error


def get_stock_price(symbol):
    """Fetch stock price for a given symbol."""
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}?interval=1d&range=1d"

    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.loads(response.read().decode())

        # Extract data
        result = data['chart']['result'][0]
        meta = result['meta']

        price = meta.get('regularMarketPrice')
        prev_close = meta.get('previousClose')
        currency = meta.get('currency', 'USD')
        name = meta.get('longName') or meta.get('symbol', symbol)
        volume = meta.get('regularMarketVolume', 'N/A')
        market_cap = meta.get('marketCap', 'N/A')

        # Calculate change
        if price and prev_close:
            change = price - prev_close
            change_pct = (change / prev_close) * 100
            change_sign = '+' if change >= 0 else ''

            # Get 52-week range
            fifty_two_week_low = meta.get('fiftyTwoWeekLow', 'N/A')
            fifty_two_week_high = meta.get('fiftyTwoWeekHigh', 'N/A')

            # Format output
            print(f"📈 {symbol.upper()} - {name}")
            print(f"Price: {currency} ${price:.2f}")
            print(f"Change: {change_sign}${change:.2f} ({change_sign}{change_pct:.2f}%)")
            print(f"Previous Close: ${prev_close:.2f}")

            if volume != 'N/A':
                volume_str = f"{volume:,}" if isinstance(volume, (int, float)) else str(volume)
                print(f"Volume: {volume_str}")

            if market_cap != 'N/A':
                if isinstance(market_cap, (int, float)):
                    if market_cap >= 1e12:
                        cap_str = f"${market_cap/1e12:.2f}T"
                    elif market_cap >= 1e9:
                        cap_str = f"${market_cap/1e9:.2f}B"
                    elif market_cap >= 1e6:
                        cap_str = f"${market_cap/1e6:.2f}M"
                    else:
                        cap_str = f"${market_cap:,.0f}"
                    print(f"Market Cap: {cap_str}")

            if fifty_two_week_low != 'N/A' and fifty_two_week_high != 'N/A':
                print(f"52-Week Range: ${fifty_two_week_low:.2f} - ${fifty_two_week_high:.2f}")

            return True
        else:
            print(f"❌ Incomplete data for {symbol.upper()}")
            return False

    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"❌ Symbol '{symbol.upper()}' not found")
        else:
            print(f"❌ HTTP Error {e.code} fetching data for {symbol.upper()}")
        return False
    except Exception as e:
        print(f"❌ Error fetching {symbol.upper()}: {str(e)}")
        return False


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 stock_price.py <SYMBOL> [SYMBOL2 ...]")
        print("Example: python3 stock_price.py AAPL TSLA NVDA")
        sys.exit(1)

    symbols = sys.argv[1:]

    for i, symbol in enumerate(symbols):
        if i > 0:
            print()  # Blank line between stocks
        get_stock_price(symbol.strip())


if __name__ == "__main__":
    main()
