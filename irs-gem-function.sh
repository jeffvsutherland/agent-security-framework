#!/bin/bash

# Function to send JVS Management note to IRS Audit Gem
send_to_irs_gem() {
    # Default to YESTERDAY'S note (completed work)
    local note_date
    if [[ "$1" == "today" ]]; then
        note_date="$(date +"%Y%m%d")"
    else
        note_date="${1:-$(date -v-1d +"%Y%m%d")}"
    fi
    local note_title="${note_date} JVS Management"
    
    echo "🔍 Retrieving note: $note_title"
    
    # Get note content and clean it for Gemini
    local content=$(osascript -e "
    tell application \"Notes\"
        try
            set notesList to every note whose name contains \"$note_title\"
            if length of notesList > 0 then
                set targetNote to item 1 of notesList
                get body of targetNote
            else
                return \"ERROR: Note '$note_title' not found\"
            end if
        on error
            return \"ERROR: Could not access note\"
        end try
    end tell
    " | sed -E 's/<[^>]*>//g' | sed 's/&nbsp;/ /g' | sed '/^$/d' | sed 's/^[[:space:]]*//')
    
    if [[ "$content" == ERROR* ]]; then
        echo "❌ $content"
        return 1
    fi
    
    echo "✅ Retrieved note content"
    echo ""
    echo "📋 FORMATTED FOR IRS AUDIT GEM:"
    echo "================================"
    echo "$content"
    echo "================================"
    echo ""
    
    # Copy to clipboard
    echo "$content" | pbcopy
    echo "✅ Content copied to clipboard"
    echo ""
    
    # Provide next steps
    echo "🤖 NEXT STEPS:"
    echo "1. Open your IRS Audit Gem in browser"
    echo "2. Paste (Cmd+V) the content into the chat"
    echo "3. Submit to generate your IRS Audit document"
    echo ""
    echo "🌐 If you provide your Gem URL, I can automate the browser opening!"
    
    return 0
}

# Export the function
export -f send_to_irs_gem

# If script is run directly, execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    send_to_irs_gem "$@"
fi