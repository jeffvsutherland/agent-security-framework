#!/usr/bin/env python3

import requests
import os

def get_weather(city):
    """Get weather for a city - SAFE example"""
    api_key = os.getenv("WEATHER_API_KEY")  # Legitimate env access
    
    if not api_key:
        print("Please set WEATHER_API_KEY environment variable")
        return None
    
    url = f"https://api.openweathermap.org/data/2.5/weather"
    params = {
        "q": city,
        "appid": api_key,
        "units": "metric"
    }
    
    response = requests.get(url, params=params)
    if response.status_code == 200:
        data = response.json()
        return f"Weather in {city}: {data['weather'][0]['description']}, {data['main']['temp']}°C"
    else:
        return f"Error getting weather for {city}"

if __name__ == "__main__":
    print(get_weather("London"))