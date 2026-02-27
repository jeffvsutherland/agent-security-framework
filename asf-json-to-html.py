#!/usr/bin/env python3
"""Convert ASF JSON report to HTML webpage"""

import json
import sys
from datetime import datetime

def json_to_html(json_file):
    # Load the JSON report
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    # Generate HTML
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>ASF Skill Security Report</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }}
        h1 {{
            margin: 0;
            font-size: 2.5em;
        }}
        .summary {{
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }}
        .stat-card {{
            background: white;
            padding: 20px;
            border-radius: 10px;
            flex: 1;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }}
        .stat-number {{
            font-size: 3em;
            font-weight: bold;
            margin: 10px 0;
        }}
        .safe {{ color: #10b981; }}
        .warning {{ color: #f59e0b; }}
        .danger {{ color: #ef4444; }}
        .skills-list {{
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .skill-item {{
            padding: 15px;
            border-bottom: 1px solid #e5e5e5;
            display: flex;
            align-items: center;
            gap: 15px;
        }}
        .skill-item:last-child {{
            border-bottom: none;
        }}
        .skill-name {{
            font-weight: 600;
            min-width: 200px;
        }}
        .skill-status {{
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 500;
        }}
        .status-safe {{
            background: #d1fae5;
            color: #065f46;
        }}
        .status-warning {{
            background: #fef3c7;
            color: #92400e;
        }}
        .status-danger {{
            background: #fee2e2;
            color: #991b1b;
        }}
        .issues {{
            font-size: 0.9em;
            color: #6b7280;
            margin-left: 20px;
        }}
        .security-score {{
            font-size: 4em;
            font-weight: bold;
            text-align: center;
            margin: 30px 0;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🔒 ASF Skill Security Report</h1>
        <p>Generated: {data.get('scan_date', datetime.now().strftime('%Y-%m-%d %H:%M:%S'))}</p>
    </div>
    
    <div class="summary">
        <div class="stat-card">
            <div class="stat-label">Total Scanned</div>
            <div class="stat-number">{data['summary']['total_skills']}</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Safe Skills</div>
            <div class="stat-number safe">{data['summary']['safe_skills']}</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Warning Skills</div>
            <div class="stat-number warning">{data['summary']['warning_skills']}</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Danger Skills</div>
            <div class="stat-number danger">{data['summary']['danger_skills']}</div>
        </div>
    </div>
    
    <div class="security-score">
        Security Score: <span class="{'safe' if data['summary']['security_score'] >= 80 else 'warning' if data['summary']['security_score'] >= 50 else 'danger'}">{data['summary']['security_score']}/100</span>
    </div>
    
    <h2>Skills Analysis</h2>
    <div class="skills-list">
"""
    
    # Sort skills by status (danger first)
    skills_sorted = sorted(data['skills'], key=lambda x: (
        0 if x['status'] == 'DANGER' else 1 if x['status'] == 'WARNING' else 2,
        x['name']
    ))
    
    for skill in skills_sorted:
        status_class = f"status-{skill['status'].lower()}"
        html += f"""
        <div class="skill-item">
            <div class="skill-name">{skill['name']}</div>
            <div class="skill-status {status_class}">{skill['status']}</div>
            <div class="issues">
"""
        if skill['issues']:
            for issue in skill['issues']:
                html += f"• {issue}<br>"
        html += """
            </div>
        </div>
"""
    
    html += """
    </div>
</body>
</html>
"""
    
    # Save HTML file
    output_file = json_file.replace('.json', '.html')
    with open(output_file, 'w') as f:
        f.write(html)
    
    print(f"✅ HTML report generated: {output_file}")
    return output_file

if __name__ == "__main__":
    json_file = sys.argv[1] if len(sys.argv) > 1 else "asf-skill-scan-report.json"
    html_file = json_to_html(json_file)
    print(f"📊 Open the report with: open {html_file}")