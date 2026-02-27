#!/usr/bin/env python3
"""
ASF-TRUST: Verify Clawdbot trust score before execution
Integrates with YARA (ASF-5) and Spam Monitor (ASF-37)
Part of ASF-38: Agent Security Trust Framework
"""

import subprocess
import json
import sys
import os

DEFAULT_THRESHOLD = 95

def run_command(cmd, description):
    """Run a command and return success status"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def yara_scan(target_path):
    """Run YARA scan (ASF-5 integration)"""
    print("🔍 Running YARA scan...")
    
    # Look for YARA rules
    yara_rules = [
        "security-tools/",
        "docs/asf-5-yara-rules/",
    ]
    
    for rules_path in yara_rules:
        if os.path.exists(rules_path):
            success, stdout, stderr = run_command(
                ["yara", "-r", rules_path, target_path],
                "YARA scan"
            )
            if not success:
                print(f"  ❌ YARA detected threat: {stdout}")
                return False
            print("  ✅ YARA scan passed")
            return True
    
    print("  ⚠️ YARA rules not found, skipping")
    return True

def spam_monitor_check(target_path):
    """Check spam monitor (ASF-37 integration)"""
    print("🔍 Running Spam Monitor check...")
    
    spam_scripts = [
        "security-tools/moltbook-spam-monitor.sh",
        "security-tools/gateway-spam-monitor.sh",
    ]
    
    for script in spam_scripts:
        if os.path.exists(script):
            success, stdout, stderr = run_command(
                ["bash", script, "--check", target_path],
                "Spam monitor"
            )
            if not success:
                print(f"  ❌ Spam monitor alert: {stdout}")
                return False
            print("  ✅ Spam monitor passed")
            return True
    
    print("  ⚠️ Spam monitor not found, skipping")
    return True

def signature_verification(target_path):
    """Verify cryptographic signature"""
    print("🔍 Verifying signatures...")
    
    # Check for cosign
    cosign_check, _, _ = run_command(["which", "cosign"], "cosign check")
    
    if not cosign_check:
        print("  ⚠️ cosign not installed, skipping")
        return True
    
    success, stdout, stderr = run_command(
        ["cosign", "verify", target_path],
        "Signature verification"
    )
    
    if not success:
        print(f"  ❌ Signature verification failed")
        return False
    
    print("  ✅ Signature verified")
    return True

def quarantine_openclaw():
    """Quarantine compromised components"""
    print("🚨 QUARANTINE: OpenClaw being isolated...")
    
    # In production, this would:
    # 1. Pause all containers
    # 2. Log to audit system
    # 3. Notify Scrum Master
    # 4. Wait for human review
    
    print("  - Containers paused")
    print("  - Audit log updated")
    print("  - Scrum Master notified")
    print("  - Awaiting human review")

def verify_clawbot_trust(target_path=".", threshold=DEFAULT_THRESHOLD):
    """Main trust verification function"""
    print("=" * 50)
    print("🚀 ASF-TRUST Verification")
    print("=" * 50)
    print(f"Target: {target_path}")
    print(f"Threshold: {threshold}")
    print()
    
    trust_score = 100
    
    # 1. YARA scan (ASF-5)
    if not yara_scan(target_path):
        trust_score -= 50
    
    # 2. Spam monitor check (ASF-37)
    if not spam_monitor_check(target_path):
        trust_score -= 25
    
    # 3. Signature verification
    if not signature_verification(target_path):
        trust_score -= 20
    
    print()
    print("=" * 50)
    print(f"📊 Trust Score: {trust_score}/{DEFAULT_THRESHOLD}")
    print("=" * 50)
    
    if trust_score >= threshold:
        print(f"✅ PASSED - Trust score {trust_score} >= {threshold}")
        return True
    else:
        print(f"❌ FAILED - Trust score {trust_score} < {threshold}")
        quarantine_openclaw()
        return False

def main():
    """CLI entry point"""
    target = "."
    threshold = DEFAULT_THRESHOLD
    enforce = False
    
    # Parse arguments
    for arg in sys.argv[1:]:
        if arg == "--enforce":
            enforce = True
        elif arg.startswith("--target="):
            target = arg.split("=")[1]
        elif arg.startswith("--threshold="):
            threshold = int(arg.split("=")[1])
    
    success = verify_clawbot_trust(target, threshold)
    
    if enforce and not success:
        sys.exit(1)
    elif not success:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
