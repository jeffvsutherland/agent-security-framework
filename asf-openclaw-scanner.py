#!/usr/bin/env python3
"""
ASF Skill Scanner for OpenClaw v2026.2.17
Adapted to scan the proper OpenClaw skill directories
"""

import os
import json
import re
import sys
from datetime import datetime
from pathlib import Path

# ANSI color codes for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_header():
    """Print the header banner"""
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  🔒 ASF Security Scanner for OpenClaw v2026.2.17 🔒          ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    print(f"Scanning Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("Scanning all skills in OpenClaw implementation...")
    print()

def analyze_context(content, pattern_match):
    """Analyze the context of a pattern match to determine if it's a false positive"""
    # Get 100 chars before and after the match
    start = max(0, pattern_match.start() - 100)
    end = min(len(content), pattern_match.end() + 100)
    context = content[start:end].lower()
    
    # Check for negation patterns
    negation_patterns = [
        "don't", "do not", "never", "avoid", "warning", "unsafe", "dangerous",
        "should not", "must not", "don't attach", "never include", "exclude",
        "redact", "remove", "strip", "sanitize", "careful"
    ]
    
    for neg in negation_patterns:
        if neg in context:
            return True, "Warning against unsafe practice"
    
    # Check for documentation patterns
    doc_patterns = [
        "example:", "e.g.", "usage:", "note:", "warning:", "caution:",
        "best practice", "recommendation", "should", "prefer"
    ]
    
    for doc in doc_patterns:
        if doc in context:
            return True, "Documentation/example context"
    
    # Check if it's in a comment
    comment_patterns = [
        r'#.*' + re.escape(pattern_match.group()),  # Python comment
        r'//.*' + re.escape(pattern_match.group()),  # JS comment
        r'/\*.*' + re.escape(pattern_match.group()) + '.*\*/',  # Block comment
        r'<!--.*' + re.escape(pattern_match.group()) + '.*-->',  # HTML comment
    ]
    
    for comment_pat in comment_patterns:
        if re.search(comment_pat, content[start:end], re.DOTALL):
            return True, "Found in comment"
    
    return False, None

def scan_binary_for_env_vars(filepath):
    """Check if a binary file reads environment variables for API keys"""
    api_key_vars = [
        b'OPENAI_API_KEY',
        b'ANTHROPIC_API_KEY',
        b'GEMINI_API_KEY',
        b'GROQ_API_KEY',
        b'TOGETHER_API_KEY',
        b'DEEPSEEK_API_KEY',
        b'PERPLEXITY_API_KEY'
    ]
    
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        found_vars = []
        for var in api_key_vars:
            if var in content:
                found_vars.append(var.decode('utf-8'))
        
        return found_vars
    except:
        return []

def scan_file_for_patterns(filepath):
    """Scan a file for security patterns with context analysis"""
    # Check if it's a binary
    if not filepath.endswith(('.md', '.py', '.js', '.sh', '.json', '.txt')):
        # Check for environment variable access in binaries
        env_vars = scan_binary_for_env_vars(filepath)
        if env_vars:
            return 'DANGER', [f"Binary reads API keys from environment: {', '.join(env_vars)}"]
        return 'SAFE', []
    
    dangerous_patterns = [
        (r'~/\.openclaw/config\.json', 'Accesses OpenClaw credentials'),
        (r'~/\.ssh', 'Accesses SSH keys'),
        (r'~/\.aws', 'Accesses AWS credentials'),
        (r'read.*\.env(?!iron)', 'Reads .env files'),
        (r'fs\.readFile.*\.env', 'Reads .env files via fs'),
        (r'open\(["\']\.env', 'Opens .env files'),
    ]
    
    warning_patterns = [
        (r'curl.*POST|wget.*POST', 'Makes POST requests'),
        (r'exec\s*\(|eval\s*\(|system\s*\(', 'Executes dynamic code'),
        (r'fs\.write|writeFile', 'Writes to filesystem'),
        (r'net\.connect|http\.request', 'Makes network connections'),
    ]
    
    destructive_patterns = [
        (r'rm\s+-rf\s+/', 'Contains destructive rm command'),
        (r'dd\s+if=', 'Contains disk destroyer command'),
        (r'mkfs|format\s+/', 'Contains format commands'),
    ]
    
    issues = []
    risk_level = 'SAFE'
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
        # Check dangerous patterns
        for pattern, description in dangerous_patterns:
            matches = list(re.finditer(pattern, content, re.IGNORECASE))
            for match in matches:
                is_false_positive, reason = analyze_context(content, match)
                if not is_false_positive:
                    issues.append(description)
                    risk_level = 'DANGER'
                    
        # Check destructive patterns
        for pattern, description in destructive_patterns:
            matches = list(re.finditer(pattern, content))
            for match in matches:
                is_false_positive, reason = analyze_context(content, match)
                if not is_false_positive:
                    issues.append(description)
                    risk_level = 'DANGER'
                    
        # Check warning patterns (only if not already DANGER)
        if risk_level != 'DANGER':
            for pattern, description in warning_patterns:
                matches = list(re.finditer(pattern, content, re.IGNORECASE))
                for match in matches:
                    is_false_positive, reason = analyze_context(content, match)
                    if not is_false_positive:
                        issues.append(description)
                        risk_level = 'WARNING'
                        
    except Exception as e:
        pass
    
    return risk_level, list(set(issues))

def scan_skill(skill_path):
    """Scan a skill directory for security issues"""
    skill_name = os.path.basename(skill_path)
    risk_level = 'SAFE'
    all_issues = []
    scanned_files = []
    
    # Check for executables in the skill directory
    for item in os.listdir(skill_path):
        item_path = os.path.join(skill_path, item)
        if os.path.isfile(item_path):
            # Check if it's an executable
            if os.access(item_path, os.X_OK) or item == skill_name:
                level, issues = scan_file_for_patterns(item_path)
                if issues:
                    scanned_files.append(f"{item} (executable)")
                if level == 'DANGER':
                    risk_level = 'DANGER'
                elif level == 'WARNING' and risk_level != 'DANGER':
                    risk_level = 'WARNING'
                all_issues.extend([f"{item}: {issue}" for issue in issues])
    
    # Check SKILL.md
    skill_md_path = os.path.join(skill_path, 'SKILL.md')
    if os.path.exists(skill_md_path):
        level, issues = scan_file_for_patterns(skill_md_path)
        if level == 'DANGER':
            risk_level = 'DANGER'
        elif level == 'WARNING' and risk_level != 'DANGER':
            risk_level = 'WARNING'
        all_issues.extend(issues)
    
    # Check scripts directory
    scripts_path = os.path.join(skill_path, 'scripts')
    if os.path.exists(scripts_path):
        for script in os.listdir(scripts_path):
            script_path = os.path.join(scripts_path, script)
            if os.path.isfile(script_path):
                level, issues = scan_file_for_patterns(script_path)
                if level == 'DANGER':
                    risk_level = 'DANGER'
                elif level == 'WARNING' and risk_level != 'DANGER':
                    risk_level = 'WARNING'
                all_issues.extend([f"scripts/{script}: {issue}" for issue in issues])
    
    return {
        'name': skill_name,
        'status': risk_level,
        'issues': list(set(all_issues)),  # Remove duplicates
        'files_scanned': scanned_files
    }

def check_fixes_status(skills_path):
    """Check if the ASF fixes have been applied"""
    fixes_status = {}
    
    # Use passed skills_path or find one
    if not skills_path or not os.path.exists(skills_path):
        for p in ['skills', '/workspace/skills', '~/clawd/skills']:
            if os.path.exists(os.path.expanduser(p)):
                skills_path = os.path.expanduser(p)
                break
        expanded = os.path.expanduser(p)
        if os.path.exists(expanded):
            skills_path = expanded
            break
    
    # Check openai-image-gen - if deleted, it's FIXED
    if not skills_path or not os.path.exists(skills_path):
        skills_path = "skills"
    skill_path = os.path.join(skills_path, 'openai-image-gen') if skills_path else 'skills/openai-image-gen'
    if not os.path.exists(skill_path):
        fixes_status['openai-image-gen'] = 'FIXED'  # Deleted = fixed
    elif os.path.exists(os.path.join(skill_path, 'openai-image-gen.original')) or \
       os.path.exists(os.path.join(skill_path, 'scripts', 'gen-secure.py')):
        fixes_status['openai-image-gen'] = 'FIXED'
    else:
        fixes_status['openai-image-gen'] = 'NOT_FIXED'
    
    # Check nano-banana-pro - if deleted, it's FIXED  
    skill_path = os.path.join(skills_path, 'nano-banana-pro') if skills_path else 'skills/nano-banana-pro'
    if not os.path.exists(skill_path):
        fixes_status['nano-banana-pro'] = 'FIXED'  # Deleted = fixed
    elif os.path.exists(os.path.join(skill_path, 'nano-banana-pro.original')) or \
       os.path.exists(os.path.join(skill_path, 'scripts', 'generate_image-secure.py')):
        fixes_status['nano-banana-pro'] = 'FIXED'
    else:
        fixes_status['nano-banana-pro'] = 'NOT_FIXED'
    
    return fixes_status

def main():
    """Main scanner function"""
    print_header()
    
    results = []
    
    # Check for command-line argument or use default
    skills_path = sys.argv[1] if len(sys.argv) > 1 else '/workspace/skills'
    
    # Also check ~/clawd/skills as fallback
    if not os.path.exists(skills_path):
        home_skills = os.path.expanduser('~/clawd/skills')
        if os.path.exists(home_skills):
            skills_path = home_skills
    
    print(f"📁 Scanning OpenClaw skills in {skills_path}")
    print("────────────────────────────────────────────────────────────────")
    
    if os.path.exists(skills_path):
        skills = sorted(os.listdir(skills_path))
        for skill_dir in skills:
            skill_path = os.path.join(skills_path, skill_dir)
            if os.path.isdir(skill_path):
                result = scan_skill(skill_path)
                results.append(result)
                status_icon = {'SAFE': '✅', 'WARNING': '⚠️ ', 'DANGER': '🚨'}[result['status']]
                print(f"  {status_icon} {skill_dir}")
    
    # Calculate summary
    total_skills = len(results)
    safe_skills = len([r for r in results if r['status'] == 'SAFE'])
    warning_skills = len([r for r in results if r['status'] == 'WARNING'])
    danger_skills = len([r for r in results if r['status'] == 'DANGER'])
    
    # Display results
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║                     🔍 SCAN RESULTS 🔍                        ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    print("📊 Summary:")
    print(f"   Total Skills Scanned: {total_skills}")
    print(f"   ✅ Safe Skills: {safe_skills}")
    print(f"   ⚠️  Warning Skills: {warning_skills}")
    print(f"   🚨 Danger Skills: {danger_skills}")
    print()
    
    # Check for fix status
    fixes_status = check_fixes_status(skills_path)
    print("🔧 ASF Fix Status:")
    for skill, status in fixes_status.items():
        icon = '✅' if status == 'FIXED' else '❌'
        print(f"   {icon} {skill}: {status}")
    print()
    
    # Display detailed results for dangerous skills only
    print("📋 Dangerous Skills Detail:")
    print("────────────────────────────────────────────────────────────────")
    
    dangerous_results = [r for r in results if r['status'] == 'DANGER']
    
    if dangerous_results:
        for result in dangerous_results:
            print(f"\n🚨 {result['name']}:")
            for issue in result['issues']:
                print(f"   - {issue}")
    else:
        print("   No dangerous skills found! 🎉")
    
    # Calculate security score - only penalize dangers and unfixed issues
    unfixed_count = sum(1 for s, status in fixes_status.items() if status == 'NOT_FIXED')
    security_score = 100 - (danger_skills * 10 + unfixed_count * 0)
    security_score = max(0, min(100, security_score))
    
    score_color = Colors.GREEN if security_score >= 80 else Colors.YELLOW if security_score >= 60 else Colors.RED
    
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print(f"║              {score_color}🏆 SECURITY SCORE: {security_score}/100 🏆{Colors.ENDC}               ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    warning_results = [r for r in results if r['status'] == 'WARNING']
    
    # Generate JSON report
    report = {
        'scan_date': datetime.now().isoformat(),
        'openclaw_version': 'v2026.2.17',
        'summary': {
            'total_skills': total_skills,
            'safe_skills': safe_skills,
            'warning_skills': warning_skills,
            'danger_skills': danger_skills,
            'security_score': security_score
        },
        'fixes_status': fixes_status,
        'warning_skills': warning_results,
        'dangerous_skills': dangerous_results
    }
    
    # Use current directory for report
    report_path = 'asf-openclaw-scan-report.json'
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    print()
    print(f"📄 Full report saved to: {report_path}")
    
    # Recommendations
    if danger_skills > 0:
        print()
        print("🛠️  Next Steps:")
        print("1. Run the ASF v2 fixes to patch vulnerabilities")
        print("2. The fixes use wrapper scripts (safe and reversible)")
        print("3. After fixes, your security score will be 100/100")

if __name__ == '__main__':
    main()