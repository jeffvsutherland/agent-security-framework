#!/usr/bin/env python3
"""Check bot membership in the REAL ASF supergroup (-1003887253177)."""
import json
import urllib.request

REAL_GROUP_ID = "-1003887253177"

BOTS = {
    "default (@jeffsutherlandbot)": ("8262532044", "8262532044:AAFo2MOi61bZL3rCK_zX7t_e7PyIDHYNhTE"),
    "research (@ASFResearchBot)": ("8371607764", "8371607764:AAEsQCxbZLi-gcDfcrc4otTg7Tj5wtVTI74"),
    "social (@ASFSocialBot)": ("8363670185", "8363670185:AAF87g3nBTkhsQ4O1TIEq1lxiRRQ7_G1BQ4"),
    "deploy (@ASFDeployBot)": ("8562304149", "8562304149:AAGG8z9voTN0UO8zfI1AjKX5z7K7mQp21ok"),
    "sales (@ASFSalesBot)": ("8049864989", "8049864989:AAHdP9iDsSpQWiQ5sKFZGJD060WLbmG5aAM"),
    "product-owner (@AgentSaturdayASFBot)": ("8319192848", "8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo"),
}

# Use first bot token for API calls
first_token = list(BOTS.values())[0][1]

print(f"=== Checking bot membership in ASF supergroup {REAL_GROUP_ID} ===\n")

for name, (bot_id, token) in BOTS.items():
    url = f"https://api.telegram.org/bot{first_token}/getChatMember?chat_id={REAL_GROUP_ID}&user_id={bot_id}"
    try:
        resp = urllib.request.urlopen(url, timeout=10)
        data = json.loads(resp.read())
        if data.get("ok"):
            member_status = data["result"].get("status", "unknown")
            if member_status in ("member", "administrator", "creator"):
                print(f"  ✅ {name} — {member_status}")
            elif member_status == "left":
                print(f"  ❌ {name} — LEFT the group (needs to be re-added)")
            elif member_status == "kicked":
                print(f"  ❌ {name} — KICKED from group")
            else:
                print(f"  ⚠️  {name} — status: {member_status}")
        else:
            print(f"  ❌ {name} — API error: {data.get('description','?')}")
    except urllib.error.HTTPError as e:
        body = json.loads(e.read())
        print(f"  ❌ {name} — {body.get('description', str(e))}")
    except Exception as e:
        print(f"  ❌ {name} — {e}")

print()
print("Bots marked ❌ need to be ADDED to the ASF group:")
print("  1. Open the 'Agent Security Framework' group in Telegram")
print("  2. Tap group name → Add Members")
print("  3. Search for each missing bot (e.g. @ASFResearchBot)")
print("  4. Add them")

