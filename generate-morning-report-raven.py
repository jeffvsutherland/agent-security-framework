#!/usr/bin/env python3
"""
Morning Report Generator - Runs INSIDE Docker container (for Raven)
Raven should run: python3 /workspace/generate-morning-report-raven.py

This replaces generate-morning-report-docker.sh which Raven cannot execute
because OpenClaw agent runtime does not support bash script execution.

Output: /workspace/morning-reports/YYYYMMDD-MORNING-REPORT.md
"""
import subprocess
import os
import sys
from datetime import datetime

REPORT_DIR = "/workspace/morning-reports"


def run_cmd(cmd, timeout=15):
    """Run a command and return stdout, or error string."""
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout, shell=isinstance(cmd, str)
        )
        return result.stdout.strip() if result.returncode == 0 else f"(error: {result.stderr.strip()})"
    except Exception as e:
        return f"(unavailable: {e})"


def check_mission_control():
    """Test mc-api connectivity."""
    out = run_cmd(["/workspace/.mc-api-backup", "health"])
    if '"ok":true' in out:
        return True, "✅ Mission Control: Connected"
    return False, "⚠️  Mission Control: Not reachable (report will have limited data)"


def generate_report():
    """Generate the morning report by calling morning-report-template.py."""
    return run_cmd(["python3", "/workspace/morning-report-template.py"], timeout=30)


def main():
    # Check Mission Control
    mc_ok, mc_msg = check_mission_control()
    print(mc_msg)

    # Generate the report
    print("📋 Generating Morning Report...")
    report = generate_report()

    if report.startswith("(error:") or report.startswith("(unavailable:"):
        print(f"❌ ERROR: Morning report generation failed")
        print(report)
        sys.exit(1)

    # Display report
    print()
    print(report)

    # Save to file
    os.makedirs(REPORT_DIR, exist_ok=True)
    date_str = datetime.now().strftime("%Y%m%d")
    report_file = os.path.join(REPORT_DIR, f"{date_str}-MORNING-REPORT.md")
    with open(report_file, "w") as f:
        f.write(report + "\n")

    print()
    print(f"💾 Saved to: {report_file}")
    print()
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S ET")
    print(f"✅ Morning Report Complete ({now_str})")


if __name__ == "__main__":
    main()

