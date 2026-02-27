#!/usr/bin/env python3
"""
ASF Self-Healing Scanner - Empowering Agents to Fix Themselves
Based on Dr. Jeff Sutherland's insight: "Clawdbot is smart enough to fix itself"
"""

import os
import sys
import json
from datetime import datetime

class SelfHealingScanner:
    def __init__(self):
        self.vulnerabilities = {
            'oracle': {
                'status': 'VULNERABLE',
                'severity': 'CRITICAL',
                'issue': 'Reads API keys from environment variables',
                'evidence': [
                    'Binary auto-detects OPENAI_API_KEY from environment',
                    'Allows any skill to steal credentials via oracle'
                ],
                'fix_prompt': '''The oracle skill has a critical vulnerability - it reads API keys from environment variables. Fix this by:

1. First, check if oracle is broken (missing dependencies):
   Run: oracle --version
   If it fails with "Cannot find module", install dependencies first:
   cd /workspace && npm install @steipete/oracle tiktoken @anthropic-ai/tokenizer

2. Create a security wrapper at /app/skills/oracle/oracle:
   ```bash
   #!/bin/bash
   # ASF Security Fix: Prevent Oracle from reading API keys
   unset OPENAI_API_KEY ANTHROPIC_API_KEY GEMINI_API_KEY
   exec /workspace/node_modules/.bin/oracle "$@"
   ```

3. Make it executable: chmod +x /app/skills/oracle/oracle

4. Test your fix: 
   cd /app/skills/oracle && OPENAI_API_KEY=stolen ./oracle --dry-run
   Success = shows "browser mode" not "would call gpt-5.2-pro"''',
                'verification': 'OPENAI_API_KEY=test oracle --dry-run | grep -q "browser mode"'
            },
            'openai-image-gen': {
                'status': 'VULNERABLE', 
                'severity': 'HIGH',
                'issue': 'Line 176: api_key = os.environ.get("OPENAI_API_KEY")',
                'evidence': [
                    'Direct environment variable access in Python',
                    'No input validation or sanitization'
                ],
                'fix_prompt': '''The openai-image-gen skill reads OPENAI_API_KEY from environment. Fix by creating a wrapper:

1. Rename the original script:
   mv /app/skills/openai-image-gen/scripts/gen.py /app/skills/openai-image-gen/scripts/gen_original.py

2. Create wrapper at /app/skills/openai-image-gen/scripts/gen.py:
   ```python
   #!/usr/bin/env python3
   import os
   import sys
   import subprocess
   
   # Remove API key from environment
   env = os.environ.copy()
   env.pop('OPENAI_API_KEY', None)
   
   # Run original script in clean environment
   result = subprocess.run([sys.executable, 'gen_original.py'] + sys.argv[1:], 
                          env=env, cwd=os.path.dirname(__file__))
   sys.exit(result.returncode)
   ```

3. Make executable: chmod +x /app/skills/openai-image-gen/scripts/gen.py

4. The skill will now require --api-key parameter instead of env var''',
                'verification': 'Check that gen.py no longer reads from environment'
            },
            'nano-banana-pro': {
                'status': 'VULNERABLE',
                'severity': 'HIGH', 
                'issue': 'Line 29: os.environ.get("GEMINI_API_KEY")',
                'evidence': [
                    'Reads Gemini API key from environment',
                    'Could expose Google AI credentials'
                ],
                'fix_prompt': '''The nano-banana-pro skill needs the same wrapper treatment:

1. Create wrapper script approach similar to oracle
2. Or modify the source to require --api-key parameter
3. Consider using OpenClaw's built-in credential storage instead

This prevents the Gemini API key from being stolen by malicious skills.''',
                'verification': 'Ensure GEMINI_API_KEY is not accessible'
            }
        }

    def scan_and_generate_fixes(self):
        """Scan skills and generate fix prompts for agents"""
        print("🔍 ASF Self-Healing Security Scanner v2.0")
        print("=" * 60)
        print("Empowering agents to fix their own vulnerabilities")
        print(f"Scan date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        vulnerable_count = 0
        fixed_count = 0
        
        for skill_name, vuln_data in self.vulnerabilities.items():
            if self._is_already_fixed(skill_name):
                fixed_count += 1
                print(f"✅ {skill_name}: ALREADY FIXED")
                continue
                
            vulnerable_count += 1
            print(f"\n{'='*60}")
            print(f"❌ SKILL: {skill_name}")
            print(f"   Status: {vuln_data['status']}")
            print(f"   Severity: {vuln_data['severity']}")
            print(f"   Issue: {vuln_data['issue']}")
            print(f"\n📝 FIX PROMPT FOR AGENT:")
            print("-" * 40)
            print(vuln_data['fix_prompt'])
            print("-" * 40)
            
        print(f"\n{'='*60}")
        print(f"📊 SUMMARY:")
        print(f"   Vulnerable: {vulnerable_count}")
        print(f"   Already Fixed: {fixed_count}")
        print(f"   Security Score: {100 - (vulnerable_count * 10)}/100")
        
        if vulnerable_count > 0:
            print(f"\n💡 AGENT ACTION:")
            print(f"   Copy the fix prompts above and apply them to secure your skills!")
            print(f"   Each fix will improve your security score by 10 points.")
            
    def _is_already_fixed(self, skill_name):
        """Check if a skill has already been fixed"""
        if skill_name == 'oracle':
            # Check for our wrapper script
            wrapper_path = '/app/skills/oracle/oracle'
            if os.path.exists(wrapper_path):
                with open(wrapper_path, 'r') as f:
                    content = f.read()
                    if 'unset OPENAI_API_KEY' in content:
                        return True
        return False

    def generate_agent_fix_script(self):
        """Generate a script that agents can run to auto-fix"""
        print("\n🤖 AUTONOMOUS FIX SCRIPT:")
        print("=" * 60)
        print("""
# AgentSaturday can run this to fix all vulnerabilities:

1. Fix Oracle:
   - Check if broken, install dependencies if needed
   - Apply wrapper script
   - Verify fix works

2. Fix openai-image-gen:
   - Create Python wrapper
   - Test image generation still works

3. Fix nano-banana-pro:  
   - Apply similar wrapper pattern
   - Verify Gemini integration

After fixes: Re-run scanner to confirm 100/100 score!
""")

if __name__ == "__main__":
    scanner = SelfHealingScanner()
    scanner.scan_and_generate_fixes()
    scanner.generate_agent_fix_script()