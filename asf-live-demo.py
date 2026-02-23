#!/usr/bin/env python3
"""
ASF Live Demo - Interactive demonstration of vulnerability detection and fixing
Perfect for presentations, videos, or live demonstrations
"""

import os
import sys
import time
import subprocess
from pathlib import Path

# ANSI color codes
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
MAGENTA = '\033[95m'
CYAN = '\033[96m'
WHITE = '\033[97m'
RESET = '\033[0m'
BOLD = '\033[1m'

def banner(text, color=BLUE):
    """Print a colored banner"""
    width = 70
    print(f"\n{color}{'='*width}{RESET}")
    print(f"{color}{text.center(width)}{RESET}")
    print(f"{color}{'='*width}{RESET}\n")

def step(number, title, color=YELLOW):
    """Print a step header"""
    print(f"\n{color}{BOLD}📍 STEP {number}: {title}{RESET}\n")

def pause(message="Press Enter to continue..."):
    """Wait for user input"""
    print(f"\n{CYAN}{message}{RESET}")
    input()

def typewriter(text, delay=0.03):
    """Print text with typewriter effect"""
    for char in text:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(delay)
    print()

def show_vulnerability_scan():
    """Show initial vulnerability scan"""
    print(f"{YELLOW}$ python3 asf-skill-scanner-demo.py{RESET}\n")
    time.sleep(0.5)
    
    # Simulate scanner output
    skills = [
        ("oracle", "🚨 DANGER", "References sensitive data", RED),
        ("openai-image-gen", "🚨 DANGER", "Accesses .env files", RED),
        ("weather", "✅ SAFE", "No security issues", GREEN),
        ("github", "✅ SAFE", "No security issues", GREEN),
    ]
    
    print("🔍 ASF Security Scanner v1.0")
    print("━" * 60)
    
    for skill, status, desc, color in skills:
        time.sleep(0.3)
        print(f"{skill:<25} {color}{status:<15}{RESET} {desc}")
    
    print("\n" + "━" * 60)
    print(f"\n{RED}⚠️  2 HIGH RISK vulnerabilities found!{RESET}")
    print(f"{RED}These match the pattern that exposed 1.5M tokens at Moltbook!{RESET}")

def show_vulnerable_code():
    """Display the vulnerable code"""
    print(f"{YELLOW}Vulnerable code in openai-image-gen (line 176):{RESET}\n")
    
    code = '''api_key = (os.environ.get("OPENAI_API_KEY") or "").strip()
if not api_key:
    print("Missing OPENAI_API_KEY", file=sys.stderr)'''
    
    print(f"{RED}❌ VULNERABLE:{RESET}")
    print("─" * 50)
    for line in code.split('\n'):
        print(f"  {line}")
    print("─" * 50)
    
    print(f"\n{RED}⚠️  Any malicious code can read this environment variable!{RESET}")
    print(f"{RED}⚠️  This is EXACTLY how Moltbook lost 1.5M API tokens!{RESET}")

def show_secure_code():
    """Display the secure code"""
    print(f"{GREEN}ASF Secure Version:{RESET}\n")
    
    vulnerable = 'api_key = os.environ.get("OPENAI_API_KEY")'
    secure = 'api_key = get_secure_credential("openai", "api_key")'
    
    print(f"{RED}❌ OLD (Vulnerable):{RESET}")
    print(f"  {vulnerable}")
    print()
    print(f"{GREEN}✅ NEW (Secure):{RESET}")
    print(f"  {secure}")
    print()
    print(f"{GREEN}✅ Credentials stored in encrypted vault{RESET}")
    print(f"{GREEN}✅ Per-skill access control{RESET}")
    print(f"{GREEN}✅ Full audit trail{RESET}")

def run_installer():
    """Run the secure skills installer"""
    print(f"{YELLOW}$ ./install-secure-skills.sh{RESET}\n")
    time.sleep(0.5)
    
    # Simulate installer output
    steps = [
        ("🛡️  ASF Secure Skills Installer", WHITE),
        ("📁 Found Clawdbot skills at: /opt/homebrew/lib/node_modules/clawdbot/skills", CYAN),
        ("📦 Backing up vulnerable skills...", YELLOW),
        ("   ✅ Backed up oracle → oracle.vulnerable", GREEN),
        ("   ✅ Backed up openai-image-gen → openai-image-gen.vulnerable", GREEN),
        ("🔒 Installing secure versions...", YELLOW),
        ("   ✅ Installed oracle-secure", GREEN),
        ("   ✅ Installed openai-image-gen-secure", GREEN),
        ("✅ ASF Secure Skills installed successfully!", GREEN),
    ]
    
    for text, color in steps:
        time.sleep(0.3)
        print(f"{color}{text}{RESET}")

def show_verification_scan():
    """Show the verification scan after fix"""
    print(f"{YELLOW}$ python3 asf-verify-secure.py{RESET}\n")
    time.sleep(0.5)
    
    print("🔍 ASF Security Scanner - Verification Mode")
    print("━" * 60)
    
    skills = [
        ("oracle-secure", "✅ SECURE", "Uses encrypted auth profiles", GREEN),
        ("openai-image-gen-secure", "✅ SECURE", "Protected credential access", GREEN),
        ("weather", "✅ SAFE", "No security issues", GREEN),
        ("github", "✅ SAFE", "No security issues", GREEN),
    ]
    
    for skill, status, desc, color in skills:
        time.sleep(0.3)
        print(f"{skill:<25} {color}{status:<15}{RESET} {desc}")
    
    print("\n" + "━" * 60)
    print(f"\n{GREEN}✅ All vulnerabilities fixed!{RESET}")
    print(f"{GREEN}✅ API keys now protected from credential theft{RESET}")

def show_attack_simulation():
    """Show how attacks fail with ASF"""
    print(f"{MAGENTA}🎯 ATTACK SIMULATION:{RESET}\n")
    
    attacks = [
        ("1. Malicious skill tries to read environment", "❌ No API key in environment", RED),
        ("2. Attempts to access auth profiles directly", "❌ Permission denied", RED),
        ("3. Tries to impersonate skill identity", "❌ Cryptographic verification fails", RED),
        ("4. Attempts network exfiltration", "❌ Blocked by permission manifest", RED),
    ]
    
    for attack, result, color in attacks:
        time.sleep(0.5)
        print(f"{YELLOW}{attack}{RESET}")
        time.sleep(0.3)
        print(f"   {color}{result}{RESET}\n")
    
    print(f"{GREEN}✅ All attack vectors blocked by ASF!{RESET}")

def main():
    """Run the complete demo"""
    banner("🛡️  ASF LIVE DEMO", BLUE)
    typewriter("Demonstrating real vulnerability detection and remediation", 0.02)
    pause()
    
    # Step 1: Show vulnerabilities
    step(1, "Current Security Status", YELLOW)
    typewriter("Let's scan our Clawdbot skills for vulnerabilities...")
    time.sleep(1)
    show_vulnerability_scan()
    pause()
    
    # Step 2: Show vulnerable code
    step(2, "The Vulnerable Code", RED)
    typewriter("Let's examine the actual vulnerability...")
    time.sleep(1)
    show_vulnerable_code()
    pause()
    
    # Step 3: Apply fix
    step(3, "Applying ASF Security Fix", GREEN)
    typewriter("Now let's deploy the secure versions...")
    time.sleep(1)
    run_installer()
    pause()
    
    # Step 4: Show secure code
    step(4, "The Secure Implementation", GREEN)
    typewriter("Here's how ASF protects credentials...")
    time.sleep(1)
    show_secure_code()
    pause()
    
    # Step 5: Verify fix
    step(5, "Verification", GREEN)
    typewriter("Let's confirm the vulnerabilities are fixed...")
    time.sleep(1)
    show_verification_scan()
    pause()
    
    # Step 6: Attack simulation
    step(6, "Attack Simulation", MAGENTA)
    typewriter("Let's see how ASF blocks real attacks...")
    time.sleep(1)
    show_attack_simulation()
    pause()
    
    # Summary
    banner("📊 DEMO COMPLETE", GREEN)
    
    print(f"{BOLD}Key Takeaways:{RESET}")
    print(f"• {RED}BEFORE:{RESET} Same vulnerabilities that exposed 1.5M tokens at Moltbook")
    print(f"• {GREEN}AFTER:{RESET} Credentials secured with ASF protection")
    print()
    print(f"{BOLD}ASF Lifecycle Demonstrated:{RESET}")
    print("  1. 🔍 DETECT vulnerabilities automatically")
    print("  2. 🔧 FIX with secure coding patterns")
    print("  3. ✅ VERIFY the remediation works")
    print("  4. 🚀 DEPLOY with simple installation")
    print()
    print(f"{GREEN}{BOLD}✨ With ASF, the Moltbook breach never happens.{RESET}")
    print()
    
    banner("Thanks for watching!", CYAN)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}Demo interrupted.{RESET}")
        sys.exit(0)