#!/usr/bin/env python3
"""
Cryptocurrency Price Checker
Uses CoinGecko API (free, no key required, better rate limits)

Usage:
    python3 crypto_price.py bitcoin
    python3 crypto_price.py bitcoin ethereum solana
"""

import sys
import json
import urllib.request
import urllib.error


CRYPTO_SYMBOLS = {
    'btc': 'bitcoin',
    'bitcoin': 'bitcoin',
    'eth': 'ethereum',
    'ethereum': 'ethereum',
    'sol': 'solana',
    'solana': 'solana',
    'ada': 'cardano',
    'cardano': 'cardano',
    'doge': 'dogecoin',
    'dogecoin': 'dogecoin',
    'xrp': 'ripple',
    'ripple': 'ripple',
    'dot': 'polkadot',
    'polkadot': 'polkadot',
    'matic': 'matic-network',
    'polygon': 'matic-network',
    'avax': 'avalanche-2',
    'avalanche': 'avalanche-2',
    'link': 'chainlink',
    'chainlink': 'chainlink',
    'uni': 'uniswap',
    'uniswap': 'uniswap',
}


def get_crypto_price(symbol):
    """Fetch crypto price using CoinGecko API."""

    # Convert common symbols to CoinGecko IDs
    symbol_lower = symbol.lower()
    crypto_id = CRYPTO_SYMBOLS.get(symbol_lower, symbol_lower)

    url = f"https://api.coingecko.com/api/v3/simple/price?ids={crypto_id}&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true"

    try:
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'Mozilla/5.0')

        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())

        if crypto_id not in data:
            print(f"❌ Cryptocurrency '{symbol}' not found")
            print(f"   Try: {', '.join(list(CRYPTO_SYMBOLS.keys())[:10])}")
            return False

        info = data[crypto_id]
        price = info.get('usd')
        change_24h = info.get('usd_24h_change')
        volume_24h = info.get('usd_24h_vol')
        market_cap = info.get('usd_market_cap')

        # Format output
        print(f"₿ {symbol.upper()} ({crypto_id.title()})")
        print(f"Price: ${price:,.2f}")

        if change_24h is not None:
            change_sign = '+' if change_24h >= 0 else ''
            emoji = '📈' if change_24h >= 0 else '📉'
            print(f"24h Change: {change_sign}{change_24h:.2f}% {emoji}")

        if volume_24h is not None:
            if volume_24h >= 1e9:
                vol_str = f"${volume_24h/1e9:.2f}B"
            elif volume_24h >= 1e6:
                vol_str = f"${volume_24h/1e6:.2f}M"
            else:
                vol_str = f"${volume_24h:,.0f}"
            print(f"24h Volume: {vol_str}")

        if market_cap is not None:
            if market_cap >= 1e12:
                cap_str = f"${market_cap/1e12:.2f}T"
            elif market_cap >= 1e9:
                cap_str = f"${market_cap/1e9:.2f}B"
            elif market_cap >= 1e6:
                cap_str = f"${market_cap/1e6:.2f}M"
            else:
                cap_str = f"${market_cap:,.0f}"
            print(f"Market Cap: {cap_str}")

        return True

    except urllib.error.HTTPError as e:
        print(f"❌ HTTP Error {e.code} fetching data for {symbol}")
        return False
    except Exception as e:
        print(f"❌ Error fetching {symbol}: {str(e)}")
        return False


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 crypto_price.py <SYMBOL> [SYMBOL2 ...]")
        print("Example: python3 crypto_price.py bitcoin ethereum solana")
        print("\nSupported symbols:")
        print("  " + ", ".join(sorted(set(CRYPTO_SYMBOLS.keys()))[:20]))
        sys.exit(1)

    symbols = sys.argv[1:]

    for i, symbol in enumerate(symbols):
        if i > 0:
            print()  # Blank line between cryptos
        get_crypto_price(symbol.strip())


if __name__ == "__main__":
    main()
