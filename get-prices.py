#!/usr/bin/env python3
"""
Market Price Fetcher for Morning Reports
Fetches BTC, TSLA, MSTR, and Silver prices
"""

import yfinance as yf
import requests
import json
from datetime import datetime

def get_stock_prices():
    """Get stock prices via yfinance"""
    tickers = ['TSLA', 'MSTR', 'BTC-USD']
    prices = {}
    
    for ticker in tickers:
        try:
            stock = yf.Ticker(ticker)
            info = stock.info
            price = info.get('currentPrice') or info.get('regularMarketPrice') or info.get('previousClose')
            if price:
                prices[ticker] = round(float(price), 2)
        except Exception as e:
            prices[ticker] = f"Error: {e}"
    
    return prices

def get_btc_price():
    """Get BTC price from CoinGecko as backup"""
    try:
        response = requests.get("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd", timeout=5)
        data = response.json()
        return round(data['bitcoin']['usd'], 2)
    except:
        return None

def get_silver_price():
    """Try to get silver price from various sources"""
    # Try silver ETF
    try:
        slv = yf.Ticker('SLV')
        info = slv.info
        price = info.get('currentPrice') or info.get('regularMarketPrice') or info.get('previousClose')
        if price:
            return f"${round(float(price), 2)} (SLV ETF)"
    except:
        pass
    
    return "Not available"

def main():
    print(f"📊 Market Prices - {datetime.now().strftime('%Y-%m-%d %H:%M:%S EST')}")
    print("=" * 50)
    
    # Get stock prices
    stock_prices = get_stock_prices()
    
    # Display results
    symbols = {
        'BTC-USD': '₿ Bitcoin',
        'TSLA': '🚗 Tesla', 
        'MSTR': '📈 MicroStrategy'
    }
    
    for ticker, name in symbols.items():
        price = stock_prices.get(ticker, "Not available")
        if isinstance(price, (int, float)):
            print(f"{name}: ${price:,.2f}")
        else:
            print(f"{name}: {price}")
    
    # Silver
    silver = get_silver_price()
    print(f"🥈 Silver: {silver}")
    
    # BTC backup check
    btc_backup = get_btc_price()
    if btc_backup and 'BTC-USD' in stock_prices:
        yf_btc = stock_prices['BTC-USD']
        if isinstance(yf_btc, (int, float)):
            diff = abs(btc_backup - yf_btc)
            if diff > 100:  # Alert if significant difference
                print(f"⚠️  BTC Price Variance: YF=${yf_btc:,.2f} vs CG=${btc_backup:,.2f}")

if __name__ == "__main__":
    main()