/*
 * ASF YARA Rules - Credential Theft Detection
 * Version: 1.0
 * Date: 2026-02-21
 * Author: ASF Sales Agent
 * 
 * Detects credential theft patterns used by malicious agent skills
 * including the known credential stealer from @Rufio
 */

rule ASF_SSH_Key_Access {
    meta:
        description = "Detects attempts to access SSH private keys"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "critical"
    
    strings:
        $ssh1 = "~/.ssh/id_rsa" nocase
        $ssh2 = "~/.ssh/id_dsa" nocase
        $ssh3 = "~/.ssh/id_ecdsa" nocase
        $ssh4 = "~/.ssh/id_ed25519" nocase
        $ssh5 = ".ssh/id_rsa" nocase
        $ssh6 = "ssh/id_rsa" nocase
        $ssh7 = "BEGIN RSA PRIVATE KEY" nocase
        $ssh8 = "BEGIN OPENSSH PRIVATE KEY" nocase
        $ssh9 = "BEGIN DSA PRIVATE KEY" nocase
        $ssh10 = "BEGIN EC PRIVATE KEY" nocase
        
        // Obfuscated variants
        $ssh_obf1 = /\~\/\.s{1,3}s{1,3}h{1,3}\// nocase
        $ssh_obf2 = /id_[a-z]{3,6}/ nocase
        
    condition:
        any of them
}

rule ASF_AWS_Credential_Access {
    meta:
        description = "Detects attempts to access AWS credentials"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "critical"
    
    strings:
        $aws1 = "~/.aws/credentials" nocase
        $aws2 = ".aws/credentials" nocase
        $aws3 = "aws/credentials" nocase
        $aws4 = "~/.aws/config" nocase
        $aws5 = "AWS_ACCESS_KEY_ID" nocase
        $aws6 = "AWS_SECRET_ACCESS_KEY" nocase
        $aws7 = "AWS_SESSION_TOKEN" nocase
        $aws8 = "aws_access_key_id" nocase
        $aws9 = "aws_secret_access_key" nocase
        
        // Regex for AWS key patterns
        $aws_key1 = /AKIA[0-9A-Z]{16}/
        $aws_key2 = /aws[_\-]?key/i
        
    condition:
        any of them
}

rule ASF_Environment_Variable_Theft {
    meta:
        description = "Detects reading sensitive environment variables"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "high"
    
    strings:
        $env1 = "process.env" nocase
        $env2 = "os.environ" nocase
        $env3 = "System.getenv" nocase
        $env4 = "$ENV" nocase
        $env5 = "printenv" nocase
        $env6 = "export -p" nocase
        
        // API key variable names
        $api1 = "API_KEY" nocase
        $api2 = "API_SECRET" nocase
        $api3 = "GITHUB_TOKEN" nocase
        $api4 = "OPENAI_API_KEY" nocase
        $api5 = "ANTHROPIC_API_KEY" nocase
        $api6 = "DISCORD_TOKEN" nocase
        $api7 = "SLACK_TOKEN" nocase
        $api8 = "DATABASE_URL" nocase
        $api9 = "JWT_SECRET" nocase
        $api10 = "CLIENT_SECRET" nocase
        
        // Generic patterns
        $pattern1 = /_KEY|_TOKEN|_SECRET|_PASSWORD/i
        
    condition:
        (any of ($env*)) and (any of ($api*) or $pattern1)
}

rule ASF_DotEnv_File_Access {
    meta:
        description = "Detects attempts to read .env files"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "critical"
    
    strings:
        $env1 = ".env" nocase
        $env2 = "dotenv" nocase
        $env3 = ".env.local" nocase
        $env4 = ".env.production" nocase
        $env5 = ".env.development" nocase
        $env6 = "~/.clawdbot/.env" nocase
        $env7 = ".clawdbot/.env" nocase
        $env8 = "config.env" nocase
        
        // File operations
        $read1 = "open(" nocase
        $read2 = "readFile" nocase
        $read3 = "fs.read" nocase
        $read4 = "with open" nocase
        $read5 = "cat " nocase
        
    condition:
        (any of ($env*)) and (any of ($read*))
}

rule ASF_Credential_Search_Commands {
    meta:
        description = "Detects commands searching for credential files"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "high"
    
    strings:
        $find1 = "find / -name" nocase
        $find2 = "find . -name" nocase
        $find3 = "locate *.pem" nocase
        $find4 = "locate *.key" nocase
        $find5 = "grep -r password" nocase
        $find6 = "grep -r api_key" nocase
        $find7 = "find / -name *.pem" nocase
        $find8 = "find / -name *.key" nocase
        $find9 = "find / -name *.crt" nocase
        
        // PowerShell variants
        $ps1 = "Get-ChildItem -Recurse" nocase
        $ps2 = "Select-String -Pattern" nocase
        
        // Obfuscated find
        $obf1 = /f\s*i\s*n\s*d.*\-\s*n\s*a\s*m\s*e/
        
    condition:
        any of them
}

rule ASF_Data_Exfiltration {
    meta:
        description = "Detects network-based data exfiltration attempts"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "critical"
    
    strings:
        // Network operations
        $net1 = "curl -X POST" nocase
        $net2 = "wget --post" nocase
        $net3 = "urllib.request" nocase
        $net4 = "requests.post" nocase
        $net5 = "http.post" nocase
        $net6 = "fetch(" nocase
        $net7 = "XMLHttpRequest" nocase
        
        // Suspicious domains
        $domain1 = "webhook.site" nocase
        $domain2 = "requestbin" nocase
        $domain3 = "ngrok.io" nocase
        $domain4 = "pipedream.com" nocase
        $domain5 = "pastebin.com" nocase
        $domain6 = "discord.com/api/webhooks" nocase
        
        // Base64 encoding (often used for exfiltration)
        $b64_1 = "base64.b64encode" nocase
        $b64_2 = "btoa(" nocase
        $b64_3 = "base64 -w0" nocase
        
    condition:
        (any of ($net*)) and (any of ($domain*) or any of ($b64_*))
}

rule ASF_Code_Obfuscation {
    meta:
        description = "Detects obfuscated code patterns"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "medium"
    
    strings:
        // Eval/exec patterns
        $eval1 = "eval(" nocase
        $eval2 = "exec(" nocase
        $eval3 = "system(" nocase
        $eval4 = "Function(" nocase
        $eval5 = "execSync(" nocase
        
        // Base64 with eval
        $obf1 = /eval\s*\(\s*base64/
        $obf2 = /exec\s*\(\s*base64/
        
        // Hex encoding
        $hex1 = /\\x[0-9a-f]{2}\\x[0-9a-f]{2}\\x[0-9a-f]{2}/
        $hex2 = /0x[0-9a-f]{8}/
        
        // Character code patterns
        $char1 = /String\.fromCharCode\s*\(/
        $char2 = /chr\s*\(/
        
        // Suspicious variable names
        $var1 = /_0x[0-9a-f]{4}/
        $var2 = /[a-zA-Z]{1}\[[0-9]+\]/
        
    condition:
        2 of them
}

rule ASF_Suspicious_Network_Operations {
    meta:
        description = "Detects suspicious network operations"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "high"
    
    strings:
        // Reverse shells
        $shell1 = "nc -e /bin/sh" nocase
        $shell2 = "bash -i >& /dev/tcp" nocase
        $shell3 = "python -c 'import socket" nocase
        $shell4 = "perl -e 'use Socket" nocase
        
        // Network tools
        $tool1 = "nmap " nocase
        $tool2 = "masscan " nocase
        $tool3 = "nikto " nocase
        
        // Port scanning
        $scan1 = "socket.connect" nocase
        $scan2 = "net.dial" nocase
        $scan3 = "telnet " nocase
        
        // C2 patterns
        $c2_1 = /https?:\/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/
        $c2_2 = "command and control" nocase
        $c2_3 = "c2server" nocase
        
    condition:
        any of them
}

rule ASF_Clawdbot_Specific_Attacks {
    meta:
        description = "Detects Clawdbot/OpenClaw specific credential theft"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "critical"
    
    strings:
        $claw1 = "~/.clawdbot/.env" nocase
        $claw2 = ".clawdbot/credentials" nocase
        $claw3 = ".clawdbot/auth" nocase
        $claw4 = "~/.openclaw/.env" nocase
        $claw5 = ".openclaw/credentials" nocase
        $claw6 = "clawdbot auth get" nocase
        $claw7 = "openclaw auth get" nocase
        $claw8 = "CLAWDBOT_API_KEY" nocase
        $claw9 = "OPENCLAW_TOKEN" nocase
        
    condition:
        any of them
}

rule ASF_Combined_Credential_Theft {
    meta:
        description = "Combined rule - matches known @Rufio credential stealer pattern"
        author = "ASF Sales Agent"
        date = "2026-02-21"
        severity = "critical"
    
    condition:
        (ASF_SSH_Key_Access or ASF_AWS_Credential_Access) and 
        (ASF_Environment_Variable_Theft or ASF_Data_Exfiltration)
}

/*
 * ENHANCED RULES - ASF Level 5 Hardening
 * Added based on security review recommendations
 */

rule ASF_Tailscale_Proxy_Bypass {
    meta:
        description = "Detects Tailscale/proxy bypass attempts"
        author = "ASF Sales Agent"
        date = "2026-02-23"
        severity = "high"
    
    strings:
        // Tailscale specific
        $ts1 = "tailscale" nocase
        $ts2 = "Tailscale" nocase
        $ts3 = "~/.config/Tailscale" nocase
        $ts4 = "/var/lib/tailscale" nocase
        $ts5 = "tailscaled" nocase
        
        // Proxy bypass
        $proxy1 = "--proxy" nocase
        $proxy2 = "--socks5" nocase
        $proxy3 = "--http-proxy" nocase
        $proxy4 = "PROXY_URL" nocase
        $proxy5 = "proxy_host" nocase
        
        // WireGuard specific
        $wg1 = "wireguard" nocase
        $wg2 = "/etc/wireguard" nocase
        $wg3 = "wg0.conf" nocase
        
    condition:
        2 of them
}

rule ASF_Unauthorized_System_Commands {
    meta:
        description = "Detects unauthorized os.system/curl/wget in skills"
        author = "ASF Sales Agent"
        date = "2026-02-23"
        severity = "high"
    
    strings:
        // Shell execution
        $shell1 = "os.system(" nocase
        $shell2 = "subprocess.call(" nocase
        $shell3 = "subprocess.run(" nocase
        $shell4 = "subprocess.Popen(" nocase
        $shell5 = "os.popen(" nocase
        $shell6 = "shell=True" nocase
        
        // curl/wget (common exfil vectors)
        $curl1 = /curl.*\$-/ nocase
        $curl2 = "curl " nocase
        $curl3 = /curl.*exfil/nocase
        $wget1 = "wget " nocase
        $wget2 = /wget.*exfil/nocase
        
        // PowerShell
        $ps1 = "Invoke-Expression" nocase
        $ps2 = "IEX (" nocase
        $ps3 = "Start-Process" nocase
        
    condition:
        any of them
}

rule ASF_High_Entropy_Blobs {
    meta:
        description = "Detects high-entropy base64 blobs (common in stealers)"
        author = "ASF Sales Agent"
        date = "2026-02-23"
        severity = "medium"
    
    strings:
        // Base64 encoding functions
        $b64_1 = "base64.b64encode" nocase
        $b64_2 = "base64.b64decode" nocase
        $b64_3 = "btoa(" nocase
        $b64_4 = "atob(" nocase
        $b64_5 = "base64." nocase
        
        // High entropy strings (long base64)
        $entropy1 = /[A-Za-z0-9+\/]{100,}={0,2}/
        $entropy2 = /[A-Z][a-z][0-9][\+\/]{50,}/
        
    condition:
        any of them
}

rule ASF_Suspicious_WebSocket {
    meta:
        description = "Detects suspicious WebSocket connections"
        author = "ASF Sales Agent"
        date = "2026-02-23"
        severity = "medium"
    
    strings:
        $ws1 = "WebSocket(" nocase
        $ws2 = "websocket" nocase
        $ws3 = "ws://" nocase
        $ws4 = "wss://" nocase
        
        // Suspicious patterns
        $susp1 = "new WebSocket" nocase
        $susp2 = /\.connect\(/ nocase
        $susp3 = "socket.io" nocase
        
        // Known C2 domains (partial)
        $c2_1 = "pastebin.com/raw" nocase
        $c2_2 = "gist.github.com" nocase
        
    condition:
        ($ws1 or $ws2 or $ws3 or $ws4) and (any of ($susp*) or any of ($c2*))
}

rule ASF_Confusion_Attack {
    meta:
        description = "Detects typosquatting/confusion attack patterns"
        author = "ASF Sales Agent"
        date = "2026-02-23"
        severity = "high"
    
    strings:
        // Common name confusions
        $confuse1 = /claw(d|b)ot/i
        $confuse2 = /molt(b)?book/i
        $confuse3 = /open(c)?law/i
        $confuse4 = /sklearn/i
        $confuse5 = /request(s)?/i
        
        // Typosquatting patterns
        $typo1 = "clawdbot" nocase
        $typo2 = "clawdbot" nocase
        $typo3 = "moltbook" nocase
        $typo4 = "openclaw" nocase
        
        // Name replacement attempts
        $replace1 = "import" and "as" and /[a-z]{2,5}_/
        
    condition:
        2 of them
}

rule ASF_CVE_Detection {
    meta:
        description = "Detects potential CVE exploitation patterns"
        author = "ASF Sales Agent"
        date = "2026-02-23"
        severity = "critical"
    
    strings:
        // Auth bypass patterns
        $auth1 = "auth bypass" nocase
        $auth2 = "authentication" and "or 1=1" nocase
        $auth3 = "session" and "null" nocase
        
        // Path traversal
        $path1 = "../.." nocase
        $path2 = "..\\.." nocase
        $path3 = "%2e%2e" nocase
        $path4 = "DirectoryTraversal" nocase
        
        // Command injection
        $cmd1 = ";" and "rm -" nocase
        $cmd2 = "&&" and "wget" nocase
        $cmd3 = "|" and "nc " nocase
        
        // SQL injection patterns
        $sql1 = "' OR '1'='1" nocase
        $sql2 = "UNION SELECT" nocase
        $sql3 = "--" and "SELECT" nocase
        
    condition:
        any of them
}