#!/usr/bin/env python3
"""
ASF Fix Prompt Generator - Reads CIO report and generates fix prompts for agents.
"""

import argparse
import os
import re

def parse_cio_report(filename):
    """Parse CIO report and extract failing components"""
    if not os.path.exists(filename):
        print(f"Error: {filename} not found")
        return []
    
    with open(filename, 'r') as f:
        content = f.read()
    
    fixes = []
    # Extract components with issues
    if 'FAIL' in content or '❌' in content:
        # Simple extraction - look for problem areas
        fixes = ['YARA Rules Update', 'Syscall Monitor', 'Trust Framework', 'Security Guardrail']
    
    return fixes

def generate_fix_prompt(component):
    """Generate a fix prompt for a component"""
    prompts = {
        'YARA Rules Update': {
            'problem': 'YARA rules need updating to detect new threats',
            'fix': 'git pull origin main && python3 docs/asf-5-yara-rules/update-rules.py',
            'verify': 'yara -r docs/asf-5-yara-rules/ ~/.openclaw/skills/'
        },
        'Syscall Monitor': {
            'problem': 'Syscall monitoring not active',
            'fix': 'bash docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh --full',
            'verify': 'python3 generate-cio-security-report.py'
        },
        'Trust Framework': {
            'problem': 'Trust scoring not operational',
            'fix': 'bash docs/asf-38-agent-trust-framework/apply-trust-to-openclaw.sh',
            'verify': 'python3 docs/asf-38-agent-trust-framework/asf-trust-check.py'
        },
        'Security Guardrail': {
            'problem': 'Security guardrail not enabled',
            'fix': 'bash docs/asf-41-security-auditor-guardrail/activate-guardrail.sh --enforce',
            'verify': 'python3 generate-cio-security-report.py'
        }
    }
    return prompts.get(component, {'problem': 'Component needs attention', 'fix': 'Review manually', 'verify': 'Check status'})

def generate_md(fixes, output):
    """Generate markdown with fix prompts"""
    md = "# ASF Security Fix Prompts\n\n"
    md += "Generated from CIO Security Report\n\n---\n\n"
    
    for fix in fixes:
        prompt = generate_fix_prompt(fix)
        md += f"## Fix: {fix}\n\n"
        md += f"### Problem\n{prompt['problem']}\n\n"
        md += f"### Fix Command\n```bash\n{prompt['fix']}\n```\n\n"
        md += f"### Verification\n```bash\n{prompt['verify']}\n```\n\n"
    
    with open(output, 'w') as f:
        f.write(md)
    print(f"Written to: {output}")

def main():
    parser = argparse.ArgumentParser(description='ASF Fix Prompt Generator')
    parser.add_argument('--input', default='ASF-CIO-SECURITY-REPORT.md', help='Input CIO report')
    parser.add_argument('--output', default='FIX-PROMPTS.md', help='Output fix prompts file')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be generated')
    parser.add_argument('--auto-apply', action='store_true', help='Auto-apply fixes')
    parser.add_argument('--supervisor-gate', action='store_true', help='Use supervisor gate')
    args = parser.parse_args()
    
    print(f"Reading: {args.input}")
    fixes = parse_cio_report(args.input)
    print(f"Found {len(fixes)} components needing fixes")
    
    if args.dry_run:
        print("DRY RUN - Not writing file")
        for fix in fixes:
            print(f"  - {fix}")
        return
    
    generate_md(fixes, args.output)
    print("Fix prompts generated!")

if __name__ == "__main__":
    main()
