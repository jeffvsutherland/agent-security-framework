#!/usr/bin/env python3
"""
Scrum Inc Website Review Script
"""
from playwright.sync_api import sync_playwright
import time

def review_website():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        print("🌐 Reviewing Scrum Inc Website...")
        print("=" * 60)
        
        # Homepage
        print("\n📄 HOMEPAGE ANALYSIS:")
        page.goto("https://www.scruminc.com", wait_until='networkidle')
        time.sleep(2)
        
        # Get title and basic info
        title = page.title()
        print(f"Title: {title}")
        
        # Get hero text
        try:
            hero = page.inner_text('h1').strip()
            print(f"Hero Headline: {hero}")
        except:
            print("Hero: Could not find H1")
            
        # Get main CTAs
        print("\n🎯 MAIN CTAs:")
        try:
            buttons = page.query_selector_all('a.btn, button, a[href*="contact"]')[:5]
            for btn in buttons:
                text = btn.inner_text().strip()
                if text:
                    print(f"  - {text}")
        except:
            print("  Could not extract CTAs")
        
        # Look for AI/automation mentions
        print("\n🤖 AI/AUTOMATION MENTIONS:")
        page_text = page.inner_text('body').lower()
        ai_keywords = ['ai', 'artificial intelligence', 'automation', 'machine learning', 'bot', 'agent']
        mentions = []
        for keyword in ai_keywords:
            if keyword in page_text:
                mentions.append(keyword)
        
        if mentions:
            print(f"  Found: {', '.join(mentions)}")
        else:
            print("  ❌ No AI/automation keywords found")
        
        # Get navigation menu
        print("\n📍 NAVIGATION STRUCTURE:")
        try:
            nav_links = page.query_selector_all('nav a, header a')[:10]
            seen = set()
            for link in nav_links:
                text = link.inner_text().strip()
                href = link.get_attribute('href')
                if text and text not in seen:
                    seen.add(text)
                    print(f"  - {text}")
        except:
            print("  Could not extract navigation")
        
        # Services/Solutions section
        print("\n💼 SERVICES/SOLUTIONS:")
        try:
            # Look for service-related sections
            services = page.query_selector_all('h2, h3')
            for service in services[:10]:
                text = service.inner_text().strip()
                if any(word in text.lower() for word in ['service', 'solution', 'consulting', 'training', 'transform']):
                    print(f"  - {text}")
        except:
            print("  Could not extract services")
        
        # Take screenshot
        print("\n📸 Taking homepage screenshot...")
        page.screenshot(path="/tmp/scruminc-homepage.png")
        print("  Screenshot saved to: /tmp/scruminc-homepage.png")
        
        browser.close()
        
        print("\n" + "=" * 60)
        print("🎯 KEY RECOMMENDATIONS:\n")
        print("1. AI INTEGRATION:")
        print("   - No AI/automation messaging found")
        print("   - Add 'Scrum + AI' as a service line")
        print("   - Include hybrid team success stories")
        print("")
        print("2. CTA STRATEGY (per Seh's 50/50 rule):")
        print("   - Current CTAs are generic")
        print("   - Add value-specific CTAs: 'AI Readiness Assessment'")
        print("   - Include downloadable resources")
        print("")
        print("3. TRUST SIGNALS:")
        print("   - Add security/compliance badges")
        print("   - Include velocity improvement metrics")
        print("   - Show enterprise client logos")
        print("")
        print("4. CONTENT GAPS:")
        print("   - No visible case studies section")
        print("   - Missing resource library/downloads")
        print("   - No blog/insights visible in nav")

if __name__ == "__main__":
    review_website()