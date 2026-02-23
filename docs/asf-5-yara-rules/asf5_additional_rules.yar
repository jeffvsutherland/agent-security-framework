/*
 * ASF-5: Advanced YARA Rules for OpenClaw Threat Detection
 * 
 * This file contains additional rules for:
 * - Tailscale/proxy bypass attempts
 * - Unauthorized curl/wget execution
 * - High-entropy base64 blobs
 * - Suspicious eval/exec patterns
 * 
 * Version: 1.0
 * Updated: 2026-02-21
 * Based on Grok Heavy review recommendations
 */

rule ASF5_Proxy_Bypass_Attempt {
    meta:
        description = "Detect proxy/Tailscale bypass attempts"
        author = "ASF Team"
        date = "2026-02-21"
        score = 70
        category = "privilege-escalation"
        
    strings:
        $tail1 = "tailscale" nocase
        $tail2 = "taildrop" nocase
        $proxy1 = "socks5://" nocase
        $proxy2 = "http://127.0.0.1:9050" nocase
        $proxy3 = "proxychains" nocase
        $bypass1 = "nc -e /bin/" nocase
        $bypass2 = "socat - TCP" nocase
        
    condition:
        any of them
}

rule ASF5_Unauthorized_Curl_Wget {
    meta:
        description = "Detect unauthorized curl/wget execution in skills"
        author = "ASF Team"
        date = "2026-02-21"
        score = 80
        category = "network-exfiltration"
        
    strings:
        $curl1 = /curl\s+-[A-Za-z\s]+\s+http/
        $curl2 = /curl\s+-[A-Za-z\s]+\s+https/
        $wget1 = /wget\s+-[A-Za-z\s]+\s+http/
        $wget2 = /wget\s+-[A-Za-z\s]+\s+https/
        $exfil1 = /curl.*\$(ENV|environ)/
        $exfil2 = /wget.*\$(ENV|environ)/
        $data1 = /curl.*--data.*\$/ nocase
        $data2 = /curl.*-d\s+.*\$/ nocase
        
    condition:
        any of them
}

rule ASF5_High_Entropy_Base64 {
    meta:
        description = "Detect high-entropy base64 blobs (common in stealers)"
        author = "ASF Team"
        date = "2026-02-21"
        score = 60
        category = "obfuscation"
        
    strings:
        $b64_1 = /[A-Za-z0-9+\/]{100,}\={0,2}/ 
        $b64_long = /[A-Za-z0-9+\/]{200,}\={0,2}/
        
    condition:
        any of them
}

rule ASF5_Suspicious_Eval_Exec {
    meta:
        description = "Detect suspicious eval/exec/os.system patterns"
        author = "ASF Team"
        date = "2026-02-21"
        score = 85
        category = "code-execution"
        
    strings:
        $eval1 = "eval("
        $eval2 = "exec("
        $exec1 = "os.system("
        $exec2 = "subprocess.call("
        $exec3 = "subprocess.run("
        $danger1 = /eval\s*\(\s*__/ nocase
        $danger2 = /exec\s*\(\s*__/ nocase
        $danger3 = /os\.system\s*\(\s*input/ nocase
        
    condition:
        any of them
}

rule ASF5_Credential_Exfiltration {
    meta:
        description = "Detect credential exfiltration patterns"
        author = "ASF Team"
        date = "2026-02-21"
        score = 90
        category = "credential-theft"
        
    strings:
        $env1 = "os.environ" 
        $env2 = "os.getenv"
        $env3 = "environ.get"
        $key1 = "API_KEY" nocase
        $key2 = "SECRET_TOKEN" nocase
        $key3 = "PASSWORD" nocase
        $key4 = "PRIVATE_KEY" nocase
        $exfil_url = /requests\.post.*\$(ENV|environ|getpass)/
        $exfil_http = /http.*\$(API_KEY|SECRET)/
        
    condition:
        ($env1 or $env2 or $env3) and (any of ($key1, $key2, $key3, $key4))
}

rule ASF5_Malicious_Skill_Indicators {
    meta:
        description = "Detect malicious skill indicators"
        author = "ASF Team"
        date = "2026-02-21"
        score = 75
        category = "malware-indicators"
        
    strings:
        $miner1 = "stratum+tcp://" nocase
        $miner2 = "xmrig" nocase
        $rat1 = "pupyrat" nocase
        $rat2 = "metasploit" nocase
        $backdoor = "python -c 'import" nocase
        $susp_import1 = "import socket" 
        $susp_import2 = "import requests"
        $susp_import3 = "import crypto"
        
    condition:
        any of them
}

rule ASF5_Confusion_Attack {
    meta:
        description = "Detect typosquatting/name-squatting patterns"
        author = "ASF Team"
        date = "2026-02-21"
        score = 65
        category = "social-engineering"
        
    strings:
        $typo1 = "clawdbot" nocase
        $typo2 = "clawdbot" nocase
        $typo3 = "moltbot" nocase
        $typo4 = "openclaw" nocase
        $fake1 = /open[_-]?claw/i
        $fake2 = /claw[_-]?bot/i
        
    condition:
        any of them
}

/*
 * Integration Notes:
 * - Run with: yara -r *.yar /path/to/scan
 * - For skill validation: yara -r *.yar skill_directory/
 * - Update rules weekly based on new IOC reports
 * - Test against benign samples to reduce false positives
 */
