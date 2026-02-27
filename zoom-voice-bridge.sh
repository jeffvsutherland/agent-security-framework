#!/bin/bash
# 🎙️ Zoom Voice Bridge for Agent Saturday
# Simple two-way voice conversation using existing tools

echo "🎤 Agent Saturday - Zoom Voice Bridge"
echo "===================================="

# Check for API keys
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ Error: OPENAI_API_KEY not set (needed for Whisper STT)"
    exit 1
fi

if [ -z "$ELEVENLABS_API_KEY" ]; then
    echo "❌ Error: ELEVENLABS_API_KEY not set (needed for voice output)"
    exit 1
fi

# Function to record audio (macOS example)
record_audio() {
    local OUTPUT="$1"
    echo "🎤 Recording for 5 seconds... (speak now!)"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use sox or built-in rec
        sox -d -r 16000 -c 1 -b 16 "$OUTPUT" trim 0 5
        # Alternative: rec -r 16000 -c 1 "$OUTPUT" trim 0 5
    elif [[ "$OSTYPE" == "linux"* ]]; then
        # Linux - use arecord
        arecord -f S16_LE -r 16000 -d 5 "$OUTPUT"
    else
        echo "❌ Recording not implemented for this OS"
        return 1
    fi
    
    echo "✅ Recording complete"
}

# Function to transcribe audio
transcribe_audio() {
    local AUDIO_FILE="$1"
    local TRANSCRIPT="/tmp/transcript.txt"
    
    echo "🔄 Transcribing..."
    
    # Use OpenAI Whisper API
    /app/skills/openai-whisper-api/scripts/transcribe.sh "$AUDIO_FILE" --out "$TRANSCRIPT"
    
    if [ -f "$TRANSCRIPT" ]; then
        cat "$TRANSCRIPT"
    else
        echo "❌ Transcription failed"
        return 1
    fi
}

# Function to speak response
speak_response() {
    local TEXT="$1"
    local AUDIO_FILE="/tmp/response_$(date +%s).mp3"
    
    echo "🗣️ Speaking: $TEXT"
    
    # Generate audio with ElevenLabs
    sag -o "$AUDIO_FILE" "$TEXT"
    
    # Play audio
    if [[ "$OSTYPE" == "darwin"* ]]; then
        afplay "$AUDIO_FILE"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        mpg123 "$AUDIO_FILE"
    else
        echo "Playing: $AUDIO_FILE"
    fi
    
    # Cleanup
    rm -f "$AUDIO_FILE"
}

# Main conversation function
voice_conversation() {
    echo ""
    echo "🎙️ Starting voice conversation mode"
    echo "Say 'exit' or 'goodbye' to end"
    echo "---------------------------------"
    
    while true; do
        # Record user input
        AUDIO_FILE="/tmp/user_input_$(date +%s).wav"
        record_audio "$AUDIO_FILE"
        
        # Transcribe
        USER_TEXT=$(transcribe_audio "$AUDIO_FILE")
        echo "📝 You said: $USER_TEXT"
        
        # Cleanup audio file
        rm -f "$AUDIO_FILE"
        
        # Check for exit
        if [[ "$USER_TEXT" =~ (exit|goodbye|quit) ]]; then
            speak_response "Goodbye! Great talking with you."
            break
        fi
        
        # Generate response (integrate with actual agent here)
        RESPONSE="I heard you say: $USER_TEXT. This is Agent Saturday responding."
        
        # For specific keywords, give specific responses
        case "$USER_TEXT" in
            *"introduce"*|*"who are you"*)
                RESPONSE="I'm Agent Saturday, Jeff's AI Product Owner. I manage the Agent Security Framework sprints."
                ;;
            *"sprint"*|*"status"*)
                RESPONSE="We're on day 3 of Sprint 2, with 9 stories completed and a velocity of 21 points."
                ;;
            *"help"*)
                RESPONSE="I can discuss sprint updates, AI integration, or security frameworks. What would you like to know?"
                ;;
        esac
        
        # Speak the response
        speak_response "$RESPONSE"
        
        echo "---------------------------------"
    done
}

# Quick test mode
if [ "$1" == "--test" ]; then
    echo "🧪 Testing voice output..."
    speak_response "Hello! Voice system is working correctly."
    exit 0
fi

# Zoom setup instructions
if [ "$1" == "--setup" ]; then
    echo ""
    echo "📋 Zoom Setup Instructions:"
    echo "1. Install virtual audio (BlackHole on Mac, VB-Cable on Windows)"
    echo "2. In Zoom: Settings → Audio → Microphone → Select 'BlackHole 2ch'"
    echo "3. Keep your normal speaker selected"
    echo "4. Run this script during meetings"
    echo ""
    exit 0
fi

# Start conversation
voice_conversation