#!/usr/bin/env python3
"""
Quick Voice Assistant for Zoom Meetings
Minimal setup, maximum functionality
"""
import os
import sys
import subprocess
import tempfile
from datetime import datetime

class VoiceAssistant:
    def __init__(self):
        # Voice responses for common scenarios
        self.responses = {
            "introduction": {
                "triggers": ["introduce", "who are you", "hello"],
                "response": "Hello! I'm Agent Saturday, also known as Raven. I'm Jeff's AI Product Owner, currently managing the Agent Security Framework Sprint 2 with a velocity of 21 points."
            },
            "sprint_update": {
                "triggers": ["sprint", "status", "update", "progress"],
                "response": "We're on day 3 of 7 in ASF Sprint 2. We've completed 9 stories including GitHub deployment and our viral Moltbook post. Our velocity is tracking at 21 points, and we've achieved an 80 out of 100 security score."
            },
            "ai_integration": {
                "triggers": ["ai integration", "artificial intelligence", "hybrid team"],
                "response": "We've proven that AI agents can be full sprint participants. In our current sprint, I participate in daily scrums, manage the backlog, and contribute to sprint reviews. The key is transparency and clear communication protocols."
            },
            "security": {
                "triggers": ["security", "vulnerability", "protection"],
                "response": "Our ASF scanner has helped secure over 13,000 agents. We've developed a self-healing approach where agents can fix their own vulnerabilities. We achieved an 80% security score by implementing wrapper scripts."
            },
            "website": {
                "triggers": ["website", "scruminc", "recommendations"],
                "response": "For the Scrum Inc website, I recommend prominently featuring AI integration as a service line. Add specific CTAs like 'Calculate Your AI Sprint Velocity' and showcase hybrid team success stories with real metrics."
            },
            "expansion_pack": {
                "triggers": ["expansion", "guide", "scrum expansion"],
                "response": "The Scrum Expansion Pack needs significant AI content expansion. I suggest adding sections on AI as team members, security frameworks for AI integration, and real velocity metrics from hybrid teams like ours."
            },
            "questions": {
                "triggers": ["question", "help", "what can you"],
                "response": "I can discuss our sprint achievements, AI integration patterns, security frameworks, or provide specific recommendations. What would you like to explore?"
            }
        }
        
    def generate_voice(self, text, output_file=None):
        """Generate voice using ElevenLabs"""
        if not output_file:
            output_file = f"/tmp/voice_{datetime.now().strftime('%Y%m%d_%H%M%S')}.mp3"
            
        try:
            # Use sag for ElevenLabs
            result = subprocess.run(
                ["sag", "-o", output_file, text],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                print(f"✅ Generated: {output_file}")
                return output_file
            else:
                print(f"❌ TTS Error: {result.stderr}")
                # Fallback to basic TTS
                return self.fallback_tts(text, output_file)
                
        except Exception as e:
            print(f"❌ Error: {e}")
            return None
            
    def fallback_tts(self, text, output_file):
        """Fallback TTS using built-in tools"""
        # Try the standard TTS tool we know works
        try:
            # This would call the TTS tool that generated the test audio earlier
            # For now, return None to indicate we should type the response
            print("💬 Would say: " + text)
            return None
        except:
            return None
            
    def quick_response(self, topic):
        """Generate a quick response for a topic"""
        topic_lower = topic.lower()
        
        # Find matching response
        for key, data in self.responses.items():
            if any(trigger in topic_lower for trigger in data["triggers"]):
                return data["response"]
                
        # Default response
        return f"Regarding {topic}, I'd be happy to provide more specific information. Could you elaborate on what aspect you'd like me to address?"
        
    def generate_all_responses(self):
        """Pre-generate all common responses"""
        print("🎤 Generating voice responses for Zoom meeting...")
        print("=" * 50)
        
        generated_files = []
        
        for key, data in self.responses.items():
            print(f"\n📝 {key.upper()}")
            print(f"   Triggers: {', '.join(data['triggers'])}")
            
            filename = f"/tmp/zoom_{key}.mp3"
            voice_file = self.generate_voice(data["response"], filename)
            
            if voice_file:
                generated_files.append((key, voice_file))
                print(f"   ✅ File: {voice_file}")
            else:
                print(f"   💬 Text ready for copy/paste")
                
        return generated_files
        
def main():
    assistant = VoiceAssistant()
    
    if len(sys.argv) > 1:
        # Generate response for specific topic
        topic = " ".join(sys.argv[1:])
        print(f"\n🎯 Generating response for: {topic}")
        
        response = assistant.quick_response(topic)
        print(f"\n📝 Response: {response}\n")
        
        voice_file = assistant.generate_voice(response)
        if voice_file:
            print(f"🎤 Voice file: {voice_file}")
            print("\n💡 Play this during the Zoom call!")
            
            # Try to play it locally
            if sys.platform == "darwin":
                subprocess.run(["afplay", voice_file])
    else:
        # Generate all responses
        files = assistant.generate_all_responses()
        
        print("\n" + "=" * 50)
        print("✅ Voice responses ready for Zoom meeting!")
        print("\n📋 Quick Commands During Meeting:")
        print("  python3 voice-assistant-quick.py introduction")
        print("  python3 voice-assistant-quick.py sprint update")
        print("  python3 voice-assistant-quick.py ai integration")
        print("  python3 voice-assistant-quick.py security")
        print("\n🎤 Or play the pre-generated files directly!")

if __name__ == "__main__":
    main()