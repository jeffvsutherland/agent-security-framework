#!/usr/bin/env python3
"""
Check current sprint status and story assignments
"""

import subprocess
import json
import sys

def run_jira_command(args):
    """Run jira-api-v3.py command and return output"""
    cmd = ['python3', '/workspace/jira-api-v3.py'] + args
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

def get_sprint_stories():
    """Get all stories and categorize by status"""
    output = run_jira_command(['issues', '--project', 'ASF'])
    
    stories = {
        'done': [],
        'in_progress': [],
        'to_do': []
    }
    
    for line in output.split('\n'):
        if line.strip().startswith('[ASF-'):
            parts = line.strip().split('] ', 1)
            if len(parts) == 2:
                story_id = parts[0].replace('[', '')
                rest = parts[1]
                if ': ' in rest:
                    status, title = rest.split(': ', 1)
                    if status == 'Done':
                        stories['done'].append({'id': story_id, 'title': title})
                    elif status == 'In Progress':
                        stories['in_progress'].append({'id': story_id, 'title': title})
                    elif status == 'To Do':
                        stories['to_do'].append({'id': story_id, 'title': title})
    
    return stories

def main():
    print("🔄 ASF Sprint Status Check")
    print("=" * 60)
    
    stories = get_sprint_stories()
    
    print(f"\n✅ Done ({len(stories['done'])} stories):")
    for story in stories['done'][:10]:
        print(f"  - {story['id']}: {story['title'][:50]}")
    
    print(f"\n🔄 In Progress ({len(stories['in_progress'])} stories):")
    for story in stories['in_progress']:
        print(f"  - {story['id']}: {story['title'][:50]}")
    
    print(f"\n📋 To Do ({len(stories['to_do'])} stories):")
    for story in stories['to_do'][:10]:
        print(f"  - {story['id']}: {story['title'][:50]}")
    
    total = len(stories['done']) + len(stories['in_progress']) + len(stories['to_do'])
    completion = (len(stories['done']) / total * 100) if total > 0 else 0
    
    print(f"\n📊 Overall Progress: {completion:.1f}% complete")
    print(f"   Total stories visible: {total}")
    
    # Check for key stories
    print("\n🎯 Key Story Status:")
    key_stories = {
        'ASF-26': 'Website Creation',
        'ASF-27': 'Message Board System',
        'ASF-23': 'Mission Control Board',
        'ASF-2': 'Docker templates',
        'ASF-3': 'Vulnerability database'
    }
    
    for story_id, desc in key_stories.items():
        status = "Unknown"
        for s in stories['done']:
            if s['id'] == story_id:
                status = "Done ✅"
                break
        for s in stories['in_progress']:
            if s['id'] == story_id:
                status = "In Progress 🔄"
                break
        for s in stories['to_do']:
            if s['id'] == story_id:
                status = "To Do 📋"
                break
        print(f"  - {story_id} ({desc}): {status}")

if __name__ == "__main__":
    main()