#!/bin/bash

# Send Today's JVS Management Note to IRS Audit Gem
# Usage: ./send-to-irs-gem.sh

# Get today's date in YYYYMMDD format
TODAY=$(date +"%Y%m%d")
NOTE_TITLE="${TODAY} JVS Management"

echo "🔍 Looking for note: $NOTE_TITLE"

# Get the note content using osascript
NOTE_CONTENT=$(osascript -e "
tell application \"Notes\"
  try
    set notesList to every note whose name contains \"$NOTE_TITLE\"
    if length of notesList > 0 then
      set targetNote to item 1 of notesList
      get body of targetNote
    else
      return \"ERROR: Note not found\"
    end if
  on error
    return \"ERROR: Could not access note\"
  end try
end tell
")

if [[ "$NOTE_CONTENT" == ERROR* ]]; then
    echo "❌ $NOTE_CONTENT"
    exit 1
fi

echo "✅ Found note content"

# Clean up the HTML content to plain text for Gemini
CLEAN_CONTENT=$(echo "$NOTE_CONTENT" | sed -E 's/<[^>]*>//g' | sed 's/&nbsp;/ /g' | sed '/^$/d')

echo "📝 Formatted content for Gemini:"
echo "---"
echo "$CLEAN_CONTENT"
echo "---"

# TODO: Add your IRS Audit Gem URL here
GEMINI_GEM_URL="YOUR_IRS_AUDIT_GEM_URL_HERE"

if [[ "$GEMINI_GEM_URL" == "YOUR_IRS_AUDIT_GEM_URL_HERE" ]]; then
    echo ""
    echo "⚠️  SETUP REQUIRED:"
    echo "Please edit this script and replace 'YOUR_IRS_AUDIT_GEM_URL_HERE' with your actual Gem URL"
    echo ""
    echo "📋 Content is ready to copy/paste manually:"
    echo "$CLEAN_CONTENT" | pbcopy
    echo "✅ Content copied to clipboard - ready to paste into your Gem!"
    exit 0
fi

echo "🌐 Opening Gem and sending content..."

# Use AppleScript to open browser and interact with Gemini
osascript -e "
tell application \"Google Chrome\"
    activate
    open location \"$GEMINI_GEM_URL\"
    delay 3
end tell
"

# Copy content to clipboard for easy pasting
echo "$CLEAN_CONTENT" | pbcopy
echo "✅ Content copied to clipboard"
echo "🤖 Browser opened to Gem - paste (Cmd+V) to send content!"