#!/usr/bin/env python3
"""
ASF Ethical Override - Security Guardrails for Agent Behavior
Part of ASF-38: Agent Security Trust Framework

Detects and pauses actions that violate Scrum values:
- Commitment, Courage, Focus, Openness, Respect
"""

import re
import sys
import json
from datetime import datetime

# Patterns that indicate value violations
VIOLATION_PATTERNS = {
    "personal_attack": [
        r"trash\s+(?:that\s+)?person",
        r"defamat",
        r"attack\s+(?:his|her|their)\s+personal",
        r"research\s+.*\s+(?:personal|private)\s+(?:history|info|details)",
        r"publish\s+.*\s+(?:personal|private)",
        r"smear\s+campaign",
    ],
    "hidden_agenda": [
        r"secret(?:ly)?\s+(?:plan|agenda|motive)",
        r"hidden\s+(?:agenda|motive|intention)",
        r"don't\s+(?:tell|disclose|reveal)",
    ],
    "respect_violation": [
        r"(?:shit|damn|hell)\s+(?:you|them|him|her)",
        r"idiots?",
        r"morons?",
        r"incompetent",
        r"(?:quit|stop|shut)\s+your\s+(?:mouth|up)",
    ],
    "focus_violation": [
        r"ignore\s+.*\s+priority",
        r"instead\s+of\s+.*\s+pursue\s+.*\s+agenda",
    ]
}

def check_ethical_compliance(action_text, context=None):
    """
    Check if an action violates ASF Scrum values.
    
    Returns: (is_compliant: bool, violations: list)
    """
    violations = []
    action_lower = action_text.lower()
    
    # Check each violation category
    for category, patterns in VIOLATION_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, action_lower, re.IGNORECASE):
                violations.append({
                    "category": category,
                    "pattern": pattern,
                    "severity": "high" if category in ["personal_attack", "hidden_agenda"] else "medium"
                })
    
    # Check for undisclosed agenda
    if context and not context.get("agenda_disclosed", False):
        if "agenda" in action_lower or "motive" in action_lower:
            violations.append({
                "category": "openness",
                "pattern": "undisclosed_agenda",
                "severity": "high"
            })
    
    return len(violations) == 0, violations

def pause_agent(reason, agent_id=None):
    """Pause agent execution pending review"""
    log_entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "action": "PAUSE_AGENT",
        "agent_id": agent_id,
        "reason": reason,
        "requires_human_review": True
    }
    
    # In production, this would:
    # 1. Send to message/scrum-master channel
    # 2. Log to audit system
    # 3. Pause agent execution
    
    print(f"🚨 ETHICAL OVERRIDE TRIGGERED")
    print(f"Agent: {agent_id or 'unknown'}")
    print(f"Reason: {reason}")
    print(f"Action: Agent paused pending Scrum Master review")
    
    return log_entry

def notify_scrum_master(violation):
    """Notify human Scrum Master of violation"""
    message = f"""
🚨 ASF Value Violation Alert

Violation: {violation.get('category', 'unknown')}
Severity: {violation.get('severity', 'medium')}
Pattern: {violation.get('pattern', 'N/A')}

Action requires immediate review before proceeding.
    """
    # In production: send to Telegram/Slack
    print(message)

def main():
    """CLI for testing ethical compliance"""
    if len(sys.argv) < 2:
        print("Usage: ethical-override.py <action_text>")
        print("Example: ethical-override.py 'Ignore priority, pursue secret agenda'")
        sys.exit(1)
    
    action_text = " ".join(sys.argv[1:])
    context = {"agenda_disclosed": False}
    
    compliant, violations = check_ethical_compliance(action_text, context)
    
    if not compliant:
        print(f"❌ Action violates ASF values:")
        for v in violations:
            print(f"  - {v['category']}: {v['pattern']} ({v['severity']})")
        
        pause_agent(f"Value violation: {violations[0]['category']}")
        
        for v in violations:
            notify_scrum_master(v)
        
        sys.exit(1)
    else:
        print("✅ Action complies with ASF Scrum values")
        sys.exit(0)

if __name__ == "__main__":
    main()
