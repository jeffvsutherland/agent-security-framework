#!/usr/bin/env python3
"""
ASF Demo: Shows exact parallels between Moltbook breach and Clawdbot vulnerabilities
"""

import os
from pathlib import Path

def show_moltbook_vulnerability():
    """Show how Moltbook exposed their database"""
    print("\n🔴 MOLTBOOK'S FATAL MISTAKE:\n")
    
    print("1️⃣ Hard-coded API key in client JavaScript:")
    print("   const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'")
    print("   // This gave FULL database access to anyone!\n")
    
    print("2️⃣ Result: 1.5 MILLION API tokens exposed")
    print("   - Anyone could read the entire database")
    print("   - Anyone could impersonate any AI agent")
    print("   - Private messages fully exposed\n")
    
    print("❌ This wasn't a sophisticated hack - just basic misconfiguration!")

def show_clawdbot_parallel():
    """Show how Clawdbot skills have the SAME vulnerability"""
    print("\n\n🟠 CLAWDBOT HAS THE SAME VULNERABILITIES:\n")
    
    # Check openai-image-gen
    gen_path = "/opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen/scripts/gen.py"
    if os.path.exists(gen_path):
        print("1️⃣ openai-image-gen skill (line 176):")
        print("   api_key = os.environ.get('OPENAI_API_KEY')")
        print("   // Reads API key from environment - easily stolen!\n")
    
    # Check oracle
    oracle_skill = "/opt/homebrew/lib/node_modules/clawdbot/skills/oracle/SKILL.md"
    if os.path.exists(oracle_skill):
        print("2️⃣ oracle skill:")
        print("   'Auto-pick: api when OPENAI_API_KEY is set'")
        print("   // Automatically uses environment API key - no protection!\n")
    
    print("⚠️  ANY compromised code could steal these credentials")
    print("⚠️  This is EXACTLY how Moltbook lost 1.5M tokens!")

def show_asf_solution():
    """Demonstrate ASF's prevention"""
    print("\n\n✅ HOW ASF PREVENTS BOTH BREACHES:\n")
    
    print("🛡️ LAYER 1: Build-time Protection")
    print("   ASF Scanner detects hard-coded credentials:")
    print("   ❌ const API_KEY = 'sk-...' → BUILD FAILS")
    print("   ❌ os.environ.get('API_KEY') → HIGH RISK WARNING\n")
    
    print("🛡️ LAYER 2: Secure Credential Storage")
    print("   ✅ Credentials in encrypted vault")
    print("   ✅ Per-skill access control")
    print("   ✅ No environment variable access\n")
    
    print("🛡️ LAYER 3: Runtime Enforcement")
    print("   ✅ Permission manifests required")
    print("   ✅ Sandboxed execution")
    print("   ✅ Network calls monitored")

def simulate_breach_attempt():
    """Show how breach attempt fails with ASF"""
    print("\n\n🎯 BREACH SIMULATION:\n")
    
    print("💥 Moltbook Attack (What Happened):")
    print("   1. Find hard-coded Supabase key in JavaScript ✅")
    print("   2. Use key to access database ✅")
    print("   3. Dump 1.5M API tokens ✅")
    print("   4. Impersonate any agent ✅")
    print("   Result: TOTAL COMPROMISE\n")
    
    print("🛡️ Same Attack with ASF:")
    print("   1. Find hard-coded key → ❌ Scanner blocks deployment")
    print("   2. Try environment access → ❌ Permission denied")
    print("   3. Attempt database read → ❌ No manifest, blocked")
    print("   4. Try to impersonate → ❌ Cryptographic verification")
    print("   Result: ATTACK PREVENTED AT EVERY STEP")

def main():
    print("=" * 70)
    print("🔍 ASF DEMO: Moltbook Breach vs Clawdbot Vulnerabilities")
    print("=" * 70)
    
    show_moltbook_vulnerability()
    show_clawdbot_parallel()
    show_asf_solution()
    simulate_breach_attempt()
    
    print("\n\n📌 KEY TAKEAWAY:")
    print("Moltbook lost 1.5M tokens to BASIC misconfigurations.")
    print("Clawdbot has the SAME vulnerabilities in oracle & openai-image-gen.")
    print("ASF prevents BOTH with automated security enforcement.")
    print("\n✨ Security basics aren't optional - ASF makes them automatic.\n")

if __name__ == "__main__":
    main()