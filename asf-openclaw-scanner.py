#!/usr/bin/env python3
"""ASF Security Scanner for OpenClaw"""
import os, re, json

def scan_file(path):
    issues = []
    try:
        with open(path, 'r', errors='ignore') as f:
            c = f.read()
            if re.search(r'os\.environ.*API_KEY', c, re.I): issues.append("API keys in env")
            if re.search(r'shell\s*=\s*True', c): issues.append("shell=True")
            if re.search(r'\beval\s*\(|\bexec\s*\(', c): issues.append("eval/exec")
    except: pass
    return issues

def scan_skill(p):
    n = os.path.basename(p)
    iss, files = [], []
    for root, _, fs in os.walk(p):
        for f in fs:
            if f.endswith(('.py','.sh','.js')):
                fp = os.path.join(root, f)
                files.append(f)
                iss.extend(scan_file(fp))
    s = 'DANGER' if any('credential' in i.lower() for i in iss) else ('WARNING' if iss else 'SAFE')
    return {'name':n,'status':s,'issues':list(set(iss)),'files':files}

print("Scanning...")
sp = None
for p in ['skills','/app/skills']:
    if os.path.exists(p): sp = p; break
if not sp: print("No skills"); exit()

results = [scan_skill(os.path.join(sp,s)) for s in sorted(os.listdir(sp)) if os.path.isdir(os.path.join(sp,s))]
safe = sum(1 for r in results if r['status']=='SAFE')
warn = sum(1 for r in results if r['status']=='WARNING')
danger = sum(1 for r in results if r['status']=='DANGER')

fixes = {}
for s in ['openai-image-gen','nano-banana-pro']:
    p = os.path.join(sp, s)
    fixes[s] = 'FIXED' if not os.path.exists(p) else ('FIXED' if os.path.exists(os.path.join(p,f'{s}.original')) else 'NOT_FIXED')

unfixed = sum(1 for v in fixes.values() if v=='NOT_FIXED')
score = max(0, 100 - danger*10 - unfixed*2)

print(f"Score: {score}/100 | Safe:{safe} Warn:{warn} Danger:{danger}")
print(f"Fixes: {fixes}")

with open('asf-openclaw-scan-report.json','w') as f:
    json.dump({'summary':{'security_score':score,'warning_skills':warn,'danger_skills':danger},
               'fixes_status':fixes,'warning_skills_detail':[r for r in results if r['status']=='WARNING'],
               'dangerous_skills':[r for r in results if r['status']=='DANGER']}, f, indent=2)
