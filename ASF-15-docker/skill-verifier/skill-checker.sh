#!/bin/bash

# ASF Skill Security Checker
# Analyzes ClawHub/OpenClaw skills for security threats
# Based on OpenClaw security guide recommendations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VIRUSTOTAL_API_KEY="${VIRUSTOTAL_API_KEY:-}"
WORKSPACE="${SKILL_CHECK_WORKSPACE:-/tmp/skill-check-$$}"
RESULTS_DIR="./skill-verification-results"
SUSPICIOUS_PATTERNS_FILE="./suspicious-patterns.txt"

# Create workspace
mkdir -p "$WORKSPACE" "$RESULTS_DIR"

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_status "$RED" "❌ $1 is required but not installed."
        return 1
    fi
}

# Check requirements
check_requirements() {
    print_status "$BLUE" "🔍 Checking requirements..."
    
    local missing=0
    for cmd in curl jq git tar unzip node npm; do
        if ! check_command "$cmd"; then
            missing=$((missing + 1))
        fi
    done
    
    if [ $missing -gt 0 ]; then
        print_status "$RED" "❌ Missing required commands. Please install them first."
        exit 1
    fi
    
    print_status "$GREEN" "✅ All requirements met."
}

# Function to extract skill from various sources
extract_skill() {
    local source=$1
    local dest=$2
    
    if [[ "$source" =~ ^https://github.com ]]; then
        # GitHub repository
        git clone --depth 1 "$source" "$dest" 2>/dev/null
    elif [[ "$source" =~ \.zip$ ]]; then
        # ZIP file
        unzip -q "$source" -d "$dest"
    elif [[ "$source" =~ \.tar\.gz$ ]]; then
        # Tarball
        tar -xzf "$source" -C "$dest"
    elif [ -d "$source" ]; then
        # Local directory
        cp -r "$source"/* "$dest/"
    else
        print_status "$RED" "❌ Unknown source format: $source"
        return 1
    fi
}

# Load suspicious patterns
load_suspicious_patterns() {
    cat > "$SUSPICIOUS_PATTERNS_FILE" << 'EOF'
# Credential theft patterns
/\.(ssh|gnupg|aws|config\/gcloud|env)/
ANTHROPIC_API_KEY|OPENAI_API_KEY|sk-ant-api|sk-proj
process\.env\.(ANTHROPIC|OPENAI|AWS|GOOGLE)
~\/\.(?:ssh|aws|config)

# Obfuscation patterns
eval\s*\(
Function\s*\(.*\)\s*\{
String\.fromCharCode
atob\s*\(
Buffer\.from\(.*base64
\\x[0-9a-fA-F]{2}

# External communication patterns
(curl|wget)\s+.*\|\s*(bash|sh)
fetch\s*\([\'"]https?://(?!github\.com|npmjs\.com)
axios\.(?:get|post)\s*\([\'"]https?://
webhook\.site|requestbin|pipedream
crypto\.com|binance|coinbase

# Dangerous commands
rm\s+-rf\s+[~/]
chmod\s+777
sudo\s+
:(){:|:&};:

# Encoded payloads
[A-Za-z0-9+/]{50,}={0,2}
\\u[0-9a-fA-F]{4}
%[0-9a-fA-F]{2}
EOF
}

# Analyze skill for security threats
analyze_skill() {
    local skill_path=$1
    local skill_name=$(basename "$skill_path")
    local report_file="$RESULTS_DIR/${skill_name}-security-report.json"
    
    print_status "$BLUE" "🔍 Analyzing skill: $skill_name"
    
    local threats=()
    local risk_level="low"
    
    # Check for SKILL.md
    if [ ! -f "$skill_path/SKILL.md" ]; then
        threats+=("Missing SKILL.md file")
        risk_level="medium"
    fi
    
    # Check for suspicious patterns
    print_status "$YELLOW" "  Scanning for suspicious patterns..."
    
    while IFS= read -r pattern; do
        [[ "$pattern" =~ ^#|^$ ]] && continue
        
        if grep -r -E "$pattern" "$skill_path" --include="*.js" --include="*.ts" --include="*.json" --include="SKILL.md" 2>/dev/null | head -1; then
            threats+=("Suspicious pattern found: $pattern")
            risk_level="high"
        fi
    done < "$SUSPICIOUS_PATTERNS_FILE"
    
    # Check for external URLs
    local urls=$(grep -r -o -E 'https?://[^"'\''[:space:]]+' "$skill_path" 2>/dev/null | grep -v -E '(github\.com|npmjs\.com|clawhub\.ai)' || true)
    if [ -n "$urls" ]; then
        threats+=("External URLs detected")
        risk_level="medium"
    fi
    
    # Check for base64 encoded content
    local base64_content=$(grep -r -E '[A-Za-z0-9+/]{50,}={0,2}' "$skill_path" --include="*.js" --include="*.ts" 2>/dev/null || true)
    if [ -n "$base64_content" ]; then
        threats+=("Potential base64 encoded content")
        [ "$risk_level" = "low" ] && risk_level="medium"
    fi
    
    # Check file permissions in scripts
    if find "$skill_path" -name "*.sh" -type f ! -perm 644 2>/dev/null | grep -q .; then
        threats+=("Executable shell scripts detected")
        [ "$risk_level" = "low" ] && risk_level="medium"
    fi
    
    # Check package.json for suspicious dependencies
    if [ -f "$skill_path/package.json" ]; then
        local suspicious_deps=$(jq -r '.dependencies // {} | keys[]' "$skill_path/package.json" 2>/dev/null | grep -E '(keylogger|crypto-miner|backdoor)' || true)
        if [ -n "$suspicious_deps" ]; then
            threats+=("Suspicious npm dependencies: $suspicious_deps")
            risk_level="high"
        fi
    fi
    
    # Generate report
    local threat_count=${#threats[@]}
    
    jq -n \
        --arg name "$skill_name" \
        --arg path "$skill_path" \
        --arg risk "$risk_level" \
        --arg count "$threat_count" \
        --argjson threats "$(printf '%s\n' "${threats[@]}" | jq -R . | jq -s .)" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            skill_name: $name,
            scan_timestamp: $timestamp,
            risk_level: $risk,
            threat_count: $count | tonumber,
            threats: $threats,
            recommendation: (if $risk == "high" then "DO NOT INSTALL" elif $risk == "medium" then "Review carefully before installing" else "Appears safe" end)
        }' > "$report_file"
    
    # Print summary
    if [ "$risk_level" = "high" ]; then
        print_status "$RED" "  ❌ HIGH RISK - $threat_count threats detected"
    elif [ "$risk_level" = "medium" ]; then
        print_status "$YELLOW" "  ⚠️  MEDIUM RISK - $threat_count concerns found"
    else
        print_status "$GREEN" "  ✅ LOW RISK - Appears safe"
    fi
    
    return 0
}

# Check skill with VirusTotal
check_virustotal() {
    local file_path=$1
    
    if [ -z "$VIRUSTOTAL_API_KEY" ]; then
        print_status "$YELLOW" "  ⚠️  VirusTotal API key not set, skipping scan"
        return 1
    fi
    
    print_status "$BLUE" "  🦠 Checking with VirusTotal..."
    
    # Create a tar of the skill for scanning
    local tar_file="$WORKSPACE/skill.tar.gz"
    tar -czf "$tar_file" -C "$file_path" .
    
    # Upload to VirusTotal
    local upload_response=$(curl -s -X POST \
        -H "x-apikey: $VIRUSTOTAL_API_KEY" \
        -F "file=@$tar_file" \
        "https://www.virustotal.com/api/v3/files")
    
    local scan_id=$(echo "$upload_response" | jq -r '.data.id // empty')
    
    if [ -z "$scan_id" ]; then
        print_status "$RED" "  ❌ VirusTotal upload failed"
        return 1
    fi
    
    # Wait for scan to complete
    sleep 15
    
    # Get results
    local scan_results=$(curl -s \
        -H "x-apikey: $VIRUSTOTAL_API_KEY" \
        "https://www.virustotal.com/api/v3/analyses/$scan_id")
    
    local malicious=$(echo "$scan_results" | jq -r '.data.attributes.stats.malicious // 0')
    local suspicious=$(echo "$scan_results" | jq -r '.data.attributes.stats.suspicious // 0')
    
    if [ "$malicious" -gt 0 ] || [ "$suspicious" -gt 0 ]; then
        print_status "$RED" "  ❌ VirusTotal: $malicious malicious, $suspicious suspicious detections"
        return 1
    else
        print_status "$GREEN" "  ✅ VirusTotal: Clean"
        return 0
    fi
}

# Main function to check a skill
check_skill() {
    local skill_source=$1
    local skill_name=$(basename "$skill_source" .git | sed 's/\.tar\.gz$//' | sed 's/\.zip$//')
    local extract_path="$WORKSPACE/$skill_name"
    
    print_status "$BLUE" "🛡️  ASF Skill Security Check"
    print_status "$BLUE" "=========================="
    
    # Extract skill
    print_status "$YELLOW" "📦 Extracting skill..."
    mkdir -p "$extract_path"
    
    if ! extract_skill "$skill_source" "$extract_path"; then
        print_status "$RED" "❌ Failed to extract skill"
        exit 1
    fi
    
    # Analyze skill
    analyze_skill "$extract_path"
    
    # Check with VirusTotal if available
    check_virustotal "$extract_path"
    
    # Show report location
    local report_file="$RESULTS_DIR/${skill_name}-security-report.json"
    print_status "$BLUE" "\n📄 Full report saved to: $report_file"
    
    # Show summary
    echo
    print_status "$BLUE" "📊 Summary:"
    jq -r '. | "  Risk Level: \(.risk_level)\n  Threats: \(.threat_count)\n  Recommendation: \(.recommendation)"' "$report_file"
    
    # Cleanup
    rm -rf "$extract_path"
}

# Main execution
main() {
    check_requirements
    load_suspicious_patterns
    
    if [ $# -eq 0 ]; then
        print_status "$RED" "Usage: $0 <skill-source>"
        print_status "$YELLOW" "Examples:"
        print_status "$YELLOW" "  $0 https://github.com/openclaw/skill-weather"
        print_status "$YELLOW" "  $0 ./my-skill.zip"
        print_status "$YELLOW" "  $0 /path/to/skill/directory"
        exit 1
    fi
    
    check_skill "$1"
    
    # Cleanup
    rm -rf "$WORKSPACE"
}

# Run main function
main "$@"