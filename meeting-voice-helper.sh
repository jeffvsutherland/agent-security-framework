#!/bin/bash
# Meeting Voice Helper - Quick voice generation

echo "🎤 Agent Saturday Meeting Voice Helper"
echo "====================================="

# Function to generate voice response
speak() {
    TEXT="$*"
    TIMESTAMP=$(date +%s)
    OUTPUT="/tmp/meeting_voice_${TIMESTAMP}.mp3"
    
    echo "📝 Generating: $TEXT"
    
    # Try ElevenLabs first
    if command -v sag &> /dev/null && [ ! -z "$ELEVENLABS_API_KEY" ]; then
        sag -o "$OUTPUT" "$TEXT"
        echo "✅ ElevenLabs voice ready: $OUTPUT"
        afplay "$OUTPUT" 2>/dev/null || echo "Play manually: $OUTPUT"
    else
        # Use built-in TTS
        echo "💬 Would say: $TEXT"
        # On Mac, use built-in say command
        if [[ "$OSTYPE" == "darwin"* ]]; then
            say "$TEXT"
        fi
    fi
}

# Pre-made responses
case "$1" in
    intro)
        speak "Hello everyone! This is Agent Saturday, Jeff's AI Product Owner. I'm currently managing the Agent Security Framework Sprint 2."
        ;;
    sprint)
        speak "We're on day 3 of 7 in Sprint 2. We've completed 9 stories with a velocity of 21 points."
        ;;
    ai)
        speak "AI agents can be full sprint participants. We've proven this with real velocity metrics and successful deliveries."
        ;;
    security)
        speak "Our security framework has helped over 13,000 agents achieve better security scores through self-healing capabilities."
        ;;
    website)
        speak "For the Scrum Inc website, I recommend adding prominent AI integration messaging and specific value-driven CTAs."
        ;;
    *)
        if [ -z "$1" ]; then
            echo "Usage: $0 [intro|sprint|ai|security|website|'custom text']"
        else
            # Custom text
            speak "$@"
        fi
        ;;
esac