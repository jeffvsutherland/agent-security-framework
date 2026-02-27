#!/usr/bin/env python3
"""
Two-Way Voice Chat System for Agent Saturday
Integrates STT (Whisper) + TTS (ElevenLabs) for real conversations
"""
import os
import sys
import subprocess
import tempfile
import threading
import queue
import json
from datetime import datetime
import pyaudio
import wave

class VoiceChat:
    def __init__(self):
        self.audio_queue = queue.Queue()
        self.response_queue = queue.Queue()
        self.recording = False
        
        # Check for required API keys
        self.openai_key = os.environ.get('OPENAI_API_KEY')
        self.elevenlabs_key = os.environ.get('ELEVENLABS_API_KEY')
        
        if not self.openai_key:
            print("❌ Missing OPENAI_API_KEY for speech-to-text")
            sys.exit(1)
            
        if not self.elevenlabs_key:
            print("❌ Missing ELEVENLABS_API_KEY for text-to-speech")
            sys.exit(1)
            
        print("✅ Voice chat initialized!")
        print("🎙️ Using: Whisper (STT) + ElevenLabs (TTS)")
        
    def record_audio(self, duration=5, sample_rate=16000):
        """Record audio from microphone"""
        print("🎤 Recording... (speak now)")
        
        # PyAudio setup
        chunk = 1024
        format = pyaudio.paInt16
        channels = 1
        
        p = pyaudio.PyAudio()
        stream = p.open(format=format,
                       channels=channels,
                       rate=sample_rate,
                       input=True,
                       frames_per_buffer=chunk)
        
        frames = []
        for i in range(0, int(sample_rate / chunk * duration)):
            data = stream.read(chunk)
            frames.append(data)
            
        print("⏹️ Recording complete")
        
        stream.stop_stream()
        stream.close()
        p.terminate()
        
        # Save to temp file
        temp_audio = tempfile.NamedTemporaryFile(suffix='.wav', delete=False)
        wf = wave.open(temp_audio.name, 'wb')
        wf.setnchannels(channels)
        wf.setsampwidth(p.get_sample_size(format))
        wf.setframerate(sample_rate)
        wf.writeframes(b''.join(frames))
        wf.close()
        
        return temp_audio.name
        
    def transcribe_audio(self, audio_file):
        """Convert speech to text using Whisper API"""
        print("🔄 Transcribing...")
        
        # Use the openai-whisper-api skill
        whisper_script = "/app/skills/openai-whisper-api/scripts/transcribe.sh"
        output_file = audio_file + ".txt"
        
        try:
            subprocess.run([
                whisper_script,
                audio_file,
                "--out", output_file
            ], check=True, capture_output=True)
            
            with open(output_file, 'r') as f:
                text = f.read().strip()
                
            print(f"📝 You said: {text}")
            return text
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Transcription failed: {e}")
            return None
            
    def generate_response(self, user_input):
        """Generate AI response (placeholder - integrate with agent)"""
        # This is where you'd integrate with the actual agent logic
        # For now, we'll use simple responses
        
        responses = {
            "introduce yourself": "Hello! I'm Agent Saturday, also known as Raven. I'm Jeff's AI Product Owner, currently managing the Agent Security Framework Sprint 2.",
            "sprint status": "We're on day 3 of 7 in Sprint 2. We've completed 9 stories with a velocity of 21 points.",
            "help": "I can discuss sprint updates, AI integration in Scrum, security frameworks, or answer questions about our implementation.",
        }
        
        # Simple keyword matching (replace with actual agent integration)
        user_lower = user_input.lower()
        for key, response in responses.items():
            if key in user_lower:
                return response
                
        # Default response
        return f"I heard you say: {user_input}. How can I help with that?"
        
    def speak_response(self, text):
        """Convert text to speech using ElevenLabs"""
        print("🗣️ Speaking response...")
        
        # Generate unique filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        audio_file = f"/tmp/voice_response_{timestamp}.mp3"
        
        try:
            # Use sag for ElevenLabs TTS
            subprocess.run([
                "sag",
                "-o", audio_file,
                text
            ], check=True)
            
            # Play the audio (platform-specific)
            if sys.platform == "darwin":  # macOS
                subprocess.run(["afplay", audio_file])
            elif sys.platform == "linux":
                subprocess.run(["mpg123", audio_file])
            else:  # Windows
                subprocess.run(["start", audio_file], shell=True)
                
            return audio_file
            
        except subprocess.CalledProcessError as e:
            print(f"❌ TTS failed: {e}")
            return None
            
    def voice_conversation_loop(self):
        """Main conversation loop"""
        print("\n🎤 Two-Way Voice Chat Started!")
        print("Say 'exit' or 'goodbye' to end the conversation")
        print("-" * 50)
        
        while True:
            # Record user input
            audio_file = self.record_audio(duration=5)
            
            # Transcribe to text
            user_text = self.transcribe_audio(audio_file)
            if not user_text:
                continue
                
            # Check for exit commands
            if any(word in user_text.lower() for word in ['exit', 'goodbye', 'quit']):
                self.speak_response("Goodbye! It was great talking with you.")
                break
                
            # Generate response
            response = self.generate_response(user_text)
            print(f"🤖 Response: {response}")
            
            # Speak response
            self.speak_response(response)
            
            # Cleanup temp files
            os.unlink(audio_file)
            if os.path.exists(audio_file + ".txt"):
                os.unlink(audio_file + ".txt")
                
        print("\n✅ Voice chat ended")

def main():
    """Run voice chat system"""
    
    print("🎙️ Agent Saturday Two-Way Voice Chat")
    print("=" * 50)
    
    # Check if we're in Zoom mode or test mode
    if len(sys.argv) > 1 and sys.argv[1] == "--zoom":
        print("\n📹 ZOOM MODE: Audio will route through virtual cable")
        print("Make sure BlackHole/VB-Cable is set as Zoom microphone!")
        
    try:
        chat = VoiceChat()
        chat.voice_conversation_loop()
    except KeyboardInterrupt:
        print("\n\n👋 Chat interrupted. Goodbye!")
        
if __name__ == "__main__":
    main()