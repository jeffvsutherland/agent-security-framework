#!/usr/bin/env python3
"""
Real-time cost burn timer - shows money wasted every second
"""
import time
import datetime

current_rate = 50  # $/hour
target_rate = 5    # $/hour
saving_rate = current_rate - target_rate

print("💸 COST BURN TIMER - EVERY SECOND COUNTS!")
print("=" * 50)
print(f"Current burn: ${current_rate}/hour")
print(f"Target burn: ${target_rate}/hour")
print(f"Potential savings: ${saving_rate}/hour")
print("=" * 50)
print("\n⏰ COST ACCUMULATOR (Press Ctrl+C to stop)\n")

start_time = time.time()

try:
    while True:
        elapsed = time.time() - start_time
        hours = elapsed / 3600
        
        current_cost = hours * current_rate
        target_cost = hours * target_rate
        wasted = current_cost - target_cost
        
        print(f"\r🔥 Burning: ${current_cost:,.2f} | Could be: ${target_cost:,.2f} | WASTED: ${wasted:,.2f}", end='', flush=True)
        
        time.sleep(0.1)
        
except KeyboardInterrupt:
    print(f"\n\n💰 In {elapsed:.0f} seconds, you could have saved ${wasted:,.2f}")
    print(f"That's ${wasted * 60 / elapsed:,.2f} per minute!")
    print(f"Or ${wasted * 3600 / elapsed:,.2f} per hour!")
    print("\n🚨 DEPLOY HAIKU NOW!")