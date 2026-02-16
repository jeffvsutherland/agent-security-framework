# Ray-Ban Meta Conversation Shortcut

## iOS Shortcut: "Talk to Clawdbot"

Create this shortcut for hands-free conversation through your glasses:

### Main Shortcut

```
Name: Talk to Clawdbot

Actions:
1. Text
   - Text: "Starting conversation mode..."
   
2. Speak
   - Text: "Hi! I'm listening. Say 'Hey Meta' to talk."
   
3. Set Variable "Listening" to "true"

4. Repeat with Each (Repeat 50 times max)
   
   5. Wait to Return (2 seconds)
   
   6. Get My Shortcuts
      - Get: Shortcuts named "Listen Once"
   
   7. Run Shortcut
      - Shortcut: "Listen Once"
      - Pass Input: Text from #1
   
   8. If (Output from #7 contains "goodbye")
      - Set Variable "Listening" to "false"
      - Exit Shortcut
   
9. Speak
   - Text: "Conversation ended."
```

### Helper Shortcut: "Listen Once"

```
Name: Listen Once

Actions:
1. Listen for Text
   - Stop Listening: After 5 seconds
   - On Device Only: Yes
   
2. If (Has any value)
   
   3. Text (What you said)
      - Text: Dictated Text
   
   4. Get Contents of URL
      - URL: http://your-mac.local:8180/api/message
      - Method: POST
      - Headers: Authorization: Bearer [token]
      - Request Body (JSON):
        {
          "message": Dictated Text,
          "source": "rayban-meta",
          "voice_response": true
        }
   
   5. Get Dictionary from (Contents of URL)
   
   6. Get text from input
      - Get: Value for "response" in Dictionary
   
   7. Speak
      - Text: Text from #6
      - Wait Until Finished: Yes
   
   8. Output: Text from #6
   
Otherwise:
   9. Nothing (timeout, continue listening)
```

## Usage

### Starting a Conversation
1. Say "Hey Siri, talk to Clawdbot"
2. Or tap the shortcut
3. Glasses will say: "Hi! I'm listening."

### During Conversation
- Just speak naturally
- Clawdbot responds through glasses speakers
- No need to say "Hey Meta" each time
- Pauses between responses for natural flow

### Example Dialogue

You: "What's the weather today?"
Clawdbot: "It's currently 72°F and sunny in your area."

You: "Should I bring an umbrella?"
Clawdbot: "No need - no rain expected today."

You: "Take a photo and describe what you see"
Clawdbot: "Taking a photo... I see an office workspace with two monitors showing code."

You: "Goodbye"
Clawdbot: "Goodbye! Ending conversation mode."

## Advanced Features

### Context-Aware Responses
The bridge maintains conversation context, so you can have natural follow-ups:

You: "What meetings do I have today?"
Clawdbot: "You have 3 meetings: 10am standup, 2pm design review, and 4pm with Sarah."

You: "What's the second one about?"
Clawdbot: "The 2pm design review is about the new dashboard mockups."

### Photo Integration
While in conversation mode:
- "Take a photo" - Captures and analyzes
- "What do you see?" - Describes current view
- "Remember this" - Saves visual memory

### Voice Commands
- "Louder" / "Quieter" - Adjust volume
- "Repeat that" - Replay last response
- "Send that to my email" - Email transcript

## Tips

1. **Better Recognition**: Speak clearly, glasses mic is good but not perfect
2. **Background Noise**: Works best in quieter environments
3. **Battery**: Continuous conversation uses more battery
4. **Privacy**: Only activates when you start it, not always listening

## Troubleshooting

**Not hearing responses?**
- Check Bluetooth connection
- Verify glasses volume isn't muted
- Ensure phone isn't on silent

**Recognition errors?**
- Speak more slowly
- Reduce background noise
- Check language settings match

**Delayed responses?**
- Check WiFi connection
- Verify gateway is running
- First response may be slower