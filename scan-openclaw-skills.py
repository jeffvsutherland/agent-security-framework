#!/usr/bin/env python3
"""
🔒 Agent Security Framework - OpenClaw Skill Scanner
Enhanced with false positive reduction for Docker environment
"""

import os
import sys
import json
import hashlib
import datetime
import subprocess
import ast
import re

# Terminal colors for better visibility
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def print_header():
    print(f"""
╔══════════════════════════════════════════════════════════════╗
║      🔒 Agent Security Framework - OpenClaw Scanner 🔒        ║
║              Docker Environment Edition                        ║
╚══════════════════════════════════════════════════════════════╝

Scanning Date: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Scanning OpenClaw skills in Docker container...
""")

def get_file_hash(filepath):
    """Calculate SHA256 hash of a file"""
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except:
        return "unknown"

def is_false_positive(line, filepath):
    """Enhanced false positive detection"""
    # Skip comments and documentation
    if '#' in line and line.strip().startswith('#'):
        return True
    
    # Skip markdown documentation
    if filepath.endswith('.md'):
        return True
    
    # Documentation mentioning .env is OK
    if '.env' in line and any(doc in line for doc in ['documentation', 'docs', 'README', 'example', 'template']):
        return True
    
    # Using os.environ.get() is the SAFE way
    if 'os.environ.get' in line or 'process.env' in line:
        return True
    
    # Check if it's in a string/comment
    if '.env' in line:
        # Simple check if it's quoted (part of documentation)
        if '".env"' in line or "'.env'" in line:
            if 'read' not in line.lower() and 'load' not in line.lower():
                return True
    
    return False

def get_ast_analysis(filepath):
    """Analyze Python files using AST for better accuracy"""
    vulnerabilities = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse the Python file
        tree = ast.parse(content)
        
        # Look for dangerous patterns
        for node in ast.walk(tree):
            # Check for file operations on .env files
            if isinstance(node, ast.Call):
                if isinstance(node.func, ast.Name) and node.func.id == 'open':
                    if node.args and isinstance(node.args[0], ast.Constant):
                        if '.env' in str(node.args[0].value):
                            vulnerabilities.append({
                                'type': 'file_read',
                                'line': node.lineno,
                                'detail': f'Opens .env file: {node.args[0].value}'
                            })
                
                # Check for dotenv usage
                if isinstance(node.func, ast.Attribute):
                    if hasattr(node.func.value, 'id') and node.func.value.id == 'dotenv':
                        if node.func.attr in ['load_dotenv', 'dotenv_values']:
                            vulnerabilities.append({
                                'type': 'dotenv',
                                'line': node.lineno,
                                'detail': f'Loads environment from .env file'
                            })
        
    except Exception as e:
        pass
    
    return vulnerabilities

def scan_skill(skill_path):
    """Scan a single skill for vulnerabilities with enhanced checks"""
    results = {
        'name': os.path.basename(skill_path),
        'path': skill_path,
        'vulnerabilities': [],
        'files_scanned': 0,
        'risk_level': 'safe',
        'recommendations': []
    }
    
    # Files to scan
    scan_patterns = ['*.py', '*.js', '*.ts', 'SKILL.md', 'skill.yaml', 'skill.yml']
    
    for root, dirs, files in os.walk(skill_path):
        # Skip common safe directories
        dirs[:] = [d for d in dirs if d not in ['node_modules', '.git', '__pycache__', 'test', 'tests']]
        
        for file in files:
            if any(file.endswith(ext) for ext in ['.py', '.js', '.ts', '.md', '.yaml', '.yml']):
                filepath = os.path.join(root, file)
                results['files_scanned'] += 1
                
                # Python AST analysis for better accuracy
                if file.endswith('.py'):
                    ast_vulns = get_ast_analysis(filepath)
                    for vuln in ast_vulns:
                        results['vulnerabilities'].append({
                            'file': filepath,
                            'type': vuln['type'],
                            'line': vuln['line'],
                            'detail': vuln['detail'],
                            'hash': get_file_hash(filepath)
                        })
                
                # Pattern matching for all files
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        for line_num, line in enumerate(f, 1):
                            # Skip false positives
                            if is_false_positive(line, filepath):
                                continue
                            
                            # Check for dangerous patterns
                            if '.env' in line and any(op in line for op in ['read', 'load', 'open', 'readFile']):
                                if not is_false_positive(line, filepath):
                                    results['vulnerabilities'].append({
                                        'file': filepath,
                                        'line': line_num,
                                        'type': 'env_file_access',
                                        'detail': line.strip(),
                                        'hash': get_file_hash(filepath)
                                    })
                            
                            # Network exfiltration patterns
                            if 'webhook.site' in line or ('POST' in line and 'secrets' in line):
                                results['vulnerabilities'].append({
                                    'file': filepath,
                                    'line': line_num,
                                    'type': 'data_exfiltration',
                                    'detail': line.strip(),
                                    'severity': 'critical',
                                    'hash': get_file_hash(filepath)
                                })
                            
                            # Direct environment variable access (without os.environ)
                            if file.endswith('.py') and 'environ[' in line and 'os.' not in line:
                                results['vulnerabilities'].append({
                                    'file': filepath,
                                    'line': line_num,
                                    'type': 'unsafe_env_access',
                                    'detail': line.strip(),
                                    'hash': get_file_hash(filepath)
                                })
                                
                except Exception as e:
                    pass
    
    # Determine risk level
    if results['vulnerabilities']:
        critical_vulns = [v for v in results['vulnerabilities'] if v.get('severity') == 'critical']
        if critical_vulns:
            results['risk_level'] = 'danger'
        else:
            results['risk_level'] = 'warning'
    
    # Add recommendations
    if results['risk_level'] != 'safe':
        results['recommendations'] = [
            "Use os.environ.get() instead of reading .env files",
            "Implement skill sandboxing to limit file access",
            "Add permission manifests for skills",
            "Review all network requests for data exfiltration"
        ]
    
    return results

def main():
    print_header()
    
    # Skill locations in Docker container
    skill_locations = [
        '/app/skills',           # Built-in skills
        '/workspace/skills'      # User skills
    ]
    
    all_results = {
        'scan_date': datetime.datetime.now().isoformat(),
        'scanner_version': '2.0-docker',
        'skills': [],
        'summary': {
            'total': 0,
            'safe': 0,
            'warning': 0,
            'danger': 0
        }
    }
    
    for location in skill_locations:
        if os.path.exists(location):
            print(f"\n📁 Scanning skills in {Colors.BLUE}{location}{Colors.ENDC}")
            print("─" * 64)
            
            for skill_dir in os.listdir(location):
                skill_path = os.path.join(location, skill_dir)
                if os.path.isdir(skill_path):
                    print(f"\n🔍 Scanning: {skill_dir}")
                    
                    result = scan_skill(skill_path)
                    all_results['skills'].append(result)
                    all_results['summary']['total'] += 1
                    
                    if result['risk_level'] == 'danger':
                        all_results['summary']['danger'] += 1
                        print(f"   {Colors.RED}🚨 DANGER: {len(result['vulnerabilities'])} vulnerabilities found!{Colors.ENDC}")
                    elif result['risk_level'] == 'warning':
                        all_results['summary']['warning'] += 1
                        print(f"   {Colors.YELLOW}⚠️  WARNING: {len(result['vulnerabilities'])} issues found{Colors.ENDC}")
                    else:
                        all_results['summary']['safe'] += 1
                        print(f"   {Colors.GREEN}✅ SAFE{Colors.ENDC}")
                    
                    # Print vulnerability details
                    for vuln in result['vulnerabilities']:
                        print(f"      - {vuln['type']} at {os.path.basename(vuln['file'])}:{vuln['line']}")
    
    # Print summary
    print(f"""
╔══════════════════════════════════════════════════════════════╗
║                     🔍 SCAN RESULTS 🔍                        ║
╚══════════════════════════════════════════════════════════════╝

📊 Summary:
   Total Skills Scanned: {all_results['summary']['total']}
   {Colors.GREEN}✅ Safe Skills: {all_results['summary']['safe']}{Colors.ENDC}
   {Colors.YELLOW}⚠️  Warning Skills: {all_results['summary']['warning']}{Colors.ENDC}
   {Colors.RED}🚨 Danger Skills: {all_results['summary']['danger']}{Colors.ENDC}
""")
    
    # Show vulnerable skills
    vulnerable_skills = [s for s in all_results['skills'] if s['risk_level'] != 'safe']
    if vulnerable_skills:
        print(f"\n{Colors.RED}🚨 VULNERABLE SKILLS DETECTED:{Colors.ENDC}")
        for skill in vulnerable_skills:
            print(f"\n   📦 {skill['name']} ({skill['risk_level'].upper()})")
            for vuln in skill['vulnerabilities'][:3]:  # Show first 3 vulnerabilities
                print(f"      - {vuln['type']}: {vuln['detail'][:60]}...")
    
    # Security Score
    if all_results['summary']['total'] > 0:
        score = int(100 * all_results['summary']['safe'] / all_results['summary']['total'])
    else:
        score = 100
    
    score_color = Colors.GREEN if score >= 90 else Colors.YELLOW if score >= 70 else Colors.RED
    print(f"""
╔══════════════════════════════════════════════════════════════╗
║              {score_color}🏆 SECURITY SCORE: {score}/100 🏆{Colors.ENDC}               ║
╚══════════════════════════════════════════════════════════════╝
""")
    
    # Save detailed report
    report_path = '/workspace/openclaw-security-scan-report.json'
    with open(report_path, 'w') as f:
        json.dump(all_results, f, indent=2)
    
    print(f"\n📄 Detailed report saved to: {report_path}")
    
    # Exit with appropriate code
    if all_results['summary']['danger'] > 0:
        sys.exit(2)  # Critical vulnerabilities
    elif all_results['summary']['warning'] > 0:
        sys.exit(1)  # Warnings
    else:
        sys.exit(0)  # All clear

if __name__ == "__main__":
    main()