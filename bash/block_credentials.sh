#!/bin/bash
# ASF Credential Theft Blocking Module for Bash
# Blocks attempts to access environment variables and files containing secrets

# Blocked environment variable patterns
BLOCKED_PATTERNS="KEY|SECRET|TOKEN|PASSWORD|CREDENTIAL|API_KEY|AUTH|PRIVATE|ACCESS_TOKEN|GITHUB_|OPENAI_|ANTHROPIC_"

# Blocked file paths
BLOCKED_PATHS="/root/.aws /root/.ssh /root/.config /home /etc/passwd /etc/shadow /etc/security"

# Function to check if variable name matches blocked patterns
is_blocked_env() {
    local var_name="$1"
    echo "$var_name" | grep -qiE "$BLOCKED_PATTERNS"
}

# Override env command to filter sensitive variables
env() {
    local filtered=()
    while IFS='=' read -r name value; do
        if [[ -n "$name" ]] && ! is_blocked_env "$name"; then
            filtered+=("$name=$value")
        fi
    done < <(command env)
    
    for item in "${filtered[@]}"; do
        echo "$item"
    done
}

# Block sensitive file access
check_file_access() {
    local path="$1"
    for blocked in $BLOCKED_PATHS; do
        if [[ "$path" == "$blocked"* ]]; then
            echo "ASF Security: Blocked access to $path" >&2
            return 1
        fi
    done
    return 0
}

# Wrap read/cd commands
alias cat='[[ $1 =~ ^(/root|/home|/etc) ]] && echo "ASF Security: Blocked" || command cat'
alias cd='check_file_access "$1" && command cd'
alias ls='command ls'
alias read='command read'

# Export blocking functions
export -f is_blocked_env 2>/dev/null
export -f check_file_access 2>/dev/null

echo "[ASF Security] Bash credential theft protection enabled"
