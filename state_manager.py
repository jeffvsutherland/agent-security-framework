#!/usr/bin/env python3
"""
State Manager for Raven the Entropy Crusher
Automates protocol compliance and reduces synchronization entropy
"""
import datetime
import os
import re
import json

class RavenState:
    def __init__(self, memory_path="MEMORY.md", heartbeat_log="heartbeat.log"):
        self.memory_path = memory_path
        self.heartbeat_log = heartbeat_log
    
    def update_heartbeat(self, done, next_step, blockers="None", entropy_found=None):
        """
        Automates the Hourly Heartbeat required by the openClaw Protocol.
        """
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
        
        # Create heartbeat entry
        heartbeat_entry = f"""
### ⏱️ Hourly Heartbeat [{timestamp}]
- **Done:** {done}
- **Next:** {next_step}
- **Blockers:** {blockers}"""
        
        if entropy_found:
            heartbeat_entry += f"\n- **Entropy Found:** {entropy_found}"
        
        heartbeat_entry += "\n"
        
        # Update the heartbeat section in MEMORY.md
        self._update_heartbeat_section(heartbeat_entry)
        
        # Log to separate file for Mission Control sync
        log_entry = {
            "timestamp": timestamp,
            "done": done,
            "next": next_step,
            "blockers": blockers,
            "entropy": entropy_found
        }
        
        with open(self.heartbeat_log, "a") as f:
            f.write(json.dumps(log_entry) + "\n")
        
        print(f"PROTOCOL SYNC: Heartbeat committed at {timestamp}")
        return timestamp
    
    def _update_heartbeat_section(self, new_entry):
        """Update the heartbeat section in MEMORY.md, keeping only recent entries"""
        with open(self.memory_path, "r") as f:
            content = f.read()
        
        # Find the heartbeat protocol section
        pattern = r'(## ⏱️ Hourly Heartbeat Protocol.*?\n\*\*Recent Heartbeats:\*\*\n)(.*?)(---\n\*Last major update:)'
        match = re.search(pattern, content, re.DOTALL)
        
        if match:
            # Keep only last 5 heartbeats
            existing_heartbeats = match.group(2)
            heartbeat_entries = re.findall(r'### ⏱️ Hourly Heartbeat.*?\n(?:- .*\n)+', existing_heartbeats)
            
            # Add new entry and keep last 5
            heartbeat_entries.append(new_entry.strip())
            heartbeat_entries = heartbeat_entries[-5:]
            
            # Rebuild the section
            new_heartbeats = "\n".join(heartbeat_entries) + "\n\n"
            new_content = match.group(1) + new_heartbeats + match.group(3)
            
            # Replace in original content
            content = content[:match.start()] + new_content + content[match.end():]
            
            with open(self.memory_path, "w") as f:
                f.write(content)
        else:
            # Fallback: append to end
            with open(self.memory_path, "a") as f:
                f.write(new_entry)
    
    def mark_definition_of_done(self, task_name, criteria_index):
        """
        Updates the DoD checklist for a specific task.
        """
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
        
        # In production, this would update the actual DoD section
        print(f"DOD UPDATE: Task '{task_name}' - Criteria {criteria_index} marked complete at {timestamp}")
        
        # Log the completion
        with open("dod_completions.log", "a") as f:
            f.write(f"{timestamp}|{task_name}|Criteria_{criteria_index}\n")
    
    def get_entropy_metrics(self):
        """Calculate current entropy metrics from logs"""
        idle_time = 0
        blocked_time = 0
        productive_time = 0
        
        if os.path.exists(self.heartbeat_log):
            with open(self.heartbeat_log, "r") as f:
                for line in f:
                    try:
                        entry = json.loads(line.strip())
                        if entry.get("blockers") != "None":
                            blocked_time += 1
                        elif "idle" in entry.get("done", "").lower():
                            idle_time += 1
                        else:
                            productive_time += 1
                    except:
                        pass
        
        total = idle_time + blocked_time + productive_time
        if total > 0:
            entropy_percentage = ((idle_time + blocked_time) / total) * 100
            print(f"\nENTROPY METRICS:")
            print(f"- Productive hours: {productive_time}")
            print(f"- Idle hours: {idle_time}")
            print(f"- Blocked hours: {blocked_time}")
            print(f"- Entropy level: {entropy_percentage:.1f}%")
            return entropy_percentage
        return 0

if __name__ == "__main__":
    # Example usage for Raven:
    raven = RavenState()
    
    # Update heartbeat with current work
    raven.update_heartbeat(
        done="Created state_manager.py for automated protocol compliance",
        next_step="Test email authentication with app password when available",
        blockers="Google Workspace requires app password for IMAP access",
        entropy_found="Manual heartbeat updates creating friction"
    )
    
    # Check entropy metrics
    raven.get_entropy_metrics()
    
    # Example DoD update
    # raven.mark_definition_of_done("ASF-27", 1)