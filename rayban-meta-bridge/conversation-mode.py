#!/usr/bin/env python3
"""
Ray-Ban Meta Conversation Mode
Enables back-and-forth dialogue with Clawdbot through glasses
"""

import os
import time
import json
import requests
import threading
import queue
from pathlib import Path

# Platform-specific imports
try:
    import speech_recognition as sr
    import pyttsx3
    SPEECH_AVAILABLE = True
except ImportError:
    SPEECH_AVAILABLE = False
    print("⚠️ Install speech_recognition and pyttsx3 for voice mode")

class ConversationBridge:
    def __init__(self, gateway_url, auth_token):
        self.gateway_url = gateway_url
        self.auth_token = auth_token
        self.conversation_active = False
        self.session_key = None
        self.message_queue = queue.Queue()
        
        # TTS engine
        if SPEECH_AVAILABLE:
            self.tts = pyttsx3.init()
            self.tts.setProperty('rate', 150)
            self.recognizer = sr.Recognizer()
            self.mic = sr.Microphone()
    
    def start_conversation(self):
        """Initialize a conversation session with Clawdbot"""
        print("🕶️ Starting conversation mode...")
        
        # Create conversation session
        response = requests.post(
            f"{self.gateway_url}/api/sessions/create",
            headers={'Authorization': f'Bearer {self.auth_token}'},
            json={
                'label': 'rayban-meta-conversation',
                'metadata': {
                    'device': 'Ray-Ban Meta',
                    'mode': 'conversation'
                }
            }
        )
        
        if response.ok:
            self.session_key = response.json()['session_key']
            self.conversation_active = True
            print(f"✅ Conversation started (session: {self.session_key[:8]}...)")
            self.speak("Hello! I'm connected through your glasses. What would you like to talk about?")
            return True
        else:
            print("❌ Failed to start conversation")
            return False
    
    def listen_continuous(self):
        """Listen for voice input through phone mic (glasses audio via Bluetooth)"""
        if not SPEECH_AVAILABLE:
            print("❌ Speech recognition not available")
            return
        
        print("🎤 Listening through phone mic...")
        
        with self.mic as source:
            self.recognizer.adjust_for_ambient_noise(source, duration=1)
        
        while self.conversation_active:
            try:
                print("👂 Listening...")
                with self.mic as source:
                    # Listen for up to 5 seconds
                    audio = self.recognizer.listen(source, timeout=1, phrase_time_limit=5)
                
                # Recognize speech
                text = self.recognizer.recognize_google(audio)
                print(f"🗣️ You: {text}")
                
                # Send to Clawdbot
                self.send_message(text)
                
            except sr.WaitTimeoutError:
                # No speech detected, continue listening
                continue
            except sr.UnknownValueError:
                # Couldn't understand audio
                continue
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"❌ Error: {e}")
                time.sleep(1)
    
    def send_message(self, message):
        """Send message to Clawdbot"""
        try:
            response = requests.post(
                f"{self.gateway_url}/api/sessions/send",
                headers={'Authorization': f'Bearer {self.auth_token}'},
                json={
                    'session_key': self.session_key,
                    'message': message,
                    'timeout_seconds': 30
                }
            )
            
            if response.ok:
                result = response.json()
                reply = result.get('response', 'No response')
                print(f"🤖 Clawdbot: {reply}")
                self.speak(reply)
            else:
                print(f"❌ Failed to send message: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error sending message: {e}")
    
    def speak(self, text):
        """Speak text through phone (heard via Bluetooth in glasses)"""
        if SPEECH_AVAILABLE and hasattr(self, 'tts'):
            self.tts.say(text)
            self.tts.runAndWait()
        else:
            # Fallback to system TTS
            try:
                if os.uname().sysname == 'Darwin':
                    os.system(f'say "{text}"')
                else:
                    os.system(f'espeak "{text}"')
            except:
                print(f"🔊 {text}")
    
    def handle_commands(self, text):
        """Handle special commands"""
        lower_text = text.lower()
        
        if "take a photo" in lower_text:
            print("📸 Photo command detected")
            # Trigger photo capture through Meta View app
            # Note: Actual implementation would integrate with Meta View API
            self.speak("Taking a photo... I'll analyze it when it syncs.")
            
        elif "what am i looking at" in lower_text:
            # Analyze last photo
            self.analyze_latest_photo()
            
        elif "remember this" in lower_text:
            # Save to Clawdbot memory
            self.save_memory(text)
            
        elif "end conversation" in lower_text or "goodbye" in lower_text:
            self.speak("Goodbye! Ending conversation mode.")
            self.conversation_active = False
    
    def analyze_latest_photo(self):
        """Analyze the most recent photo"""
        # This would integrate with the photo bridge
        self.speak("Analyzing your view... I see a development workspace with code on the screen.")
    
    def save_memory(self, context):
        """Save to Clawdbot memory"""
        self.send_message(f"Please remember: {context}")
    
    def conversation_loop(self):
        """Main conversation loop"""
        if not self.start_conversation():
            return
        
        # Start listening thread
        listen_thread = threading.Thread(target=self.listen_continuous)
        listen_thread.start()
        
        try:
            # Keep conversation alive
            while self.conversation_active:
                time.sleep(1)
                
        except KeyboardInterrupt:
            print("\n👋 Ending conversation...")
        finally:
            self.conversation_active = False
            self.speak("Conversation ended.")

# Simple text-based version for testing
class TextConversationBridge(ConversationBridge):
    """Text-based conversation for platforms without speech"""
    
    def listen_continuous(self):
        """Read text input instead of speech"""
        print("\n💬 Text conversation mode (type 'exit' to quit)")
        print("You can say things like:")
        print("  - 'What's the weather?'")
        print("  - 'Take a photo'")
        print("  - 'What am I looking at?'")
        print("  - 'Remember this meeting is at 3pm'")
        print("")
        
        while self.conversation_active:
            try:
                message = input("You: ")
                if message.lower() in ['exit', 'quit', 'bye', 'goodbye']:
                    self.conversation_active = False
                    break
                
                # Handle special commands
                self.handle_commands(message)
                
                # Send to Clawdbot
                if self.conversation_active:
                    self.send_message(message)
                    
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"❌ Error: {e}")

def main():
    """Run conversation bridge"""
    import sys
    
    # Configuration
    GATEWAY_URL = os.getenv('CLAWDBOT_GATEWAY', 'http://localhost:8180')
    AUTH_TOKEN = os.getenv('CLAWDBOT_TOKEN', 'your-token-here')
    
    # Command line args
    if len(sys.argv) > 1:
        GATEWAY_URL = sys.argv[1]
    if len(sys.argv) > 2:
        AUTH_TOKEN = sys.argv[2]
    
    print("🕶️ Ray-Ban Meta × Clawdbot Conversation Mode")
    print("=" * 50)
    
    # Choose mode based on available features
    if SPEECH_AVAILABLE and '--text' not in sys.argv:
        print("🎤 Voice mode enabled")
        bridge = ConversationBridge(GATEWAY_URL, AUTH_TOKEN)
    else:
        print("💬 Text mode (install speech_recognition for voice)")
        bridge = TextConversationBridge(GATEWAY_URL, AUTH_TOKEN)
    
    # Start conversation
    bridge.conversation_loop()

if __name__ == '__main__':
    main()