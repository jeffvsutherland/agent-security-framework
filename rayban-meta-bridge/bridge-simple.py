#!/usr/bin/env python3
"""
Simple Ray-Ban Meta → Clawdbot Bridge
Works with Pythonista (iOS) or Termux (Android)
"""

import os
import time
import base64
import json
import requests
from pathlib import Path
from datetime import datetime, timedelta

class MetaGlassesBridge:
    def __init__(self, gateway_url, auth_token):
        self.gateway_url = gateway_url
        self.auth_token = auth_token
        self.processed = set()
        
        # Photo locations by platform
        self.photo_dirs = self.find_photo_dirs()
        
    def find_photo_dirs(self):
        """Find where Meta View saves photos"""
        possible_dirs = [
            # iOS Pythonista
            Path.home() / "Documents" / "Meta View",
            Path("/private/var/mobile/Media/PhotoData/Metadata"),
            # Android Termux
            Path("/sdcard/DCIM/Meta View"),
            Path("/storage/emulated/0/DCIM/Meta View"),
            # Generic
            Path.home() / "Pictures" / "Meta View",
        ]
        
        return [d for d in possible_dirs if d.exists()]
    
    def monitor_photos(self, check_interval=3):
        """Monitor for new photos from glasses"""
        print("🕶️ Ray-Ban Meta Bridge Active")
        print(f"📡 Connected to: {self.gateway_url}")
        print(f"📁 Monitoring: {', '.join(str(d) for d in self.photo_dirs)}")
        
        while True:
            try:
                # Check for photos from last 5 minutes
                cutoff_time = datetime.now() - timedelta(minutes=5)
                
                for photo_dir in self.photo_dirs:
                    self.check_directory(photo_dir, cutoff_time)
                
                time.sleep(check_interval)
                
            except KeyboardInterrupt:
                print("\n👋 Bridge stopped")
                break
            except Exception as e:
                print(f"❌ Error: {e}")
                time.sleep(check_interval)
    
    def check_directory(self, directory, cutoff_time):
        """Check directory for new media files"""
        for file_path in directory.rglob("*"):
            if file_path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.mp4', '.mov']:
                # Check if file is new
                if file_path.stat().st_mtime > cutoff_time.timestamp():
                    if str(file_path) not in self.processed:
                        self.process_file(file_path)
                        self.processed.add(str(file_path))
    
    def process_file(self, file_path):
        """Send file to Clawdbot for processing"""
        print(f"\n📸 New capture: {file_path.name}")
        
        try:
            # Read file
            with open(file_path, 'rb') as f:
                file_data = f.read()
            
            # Prepare request
            files = {'file': (file_path.name, file_data)}
            headers = {'Authorization': f'Bearer {self.auth_token}'}
            data = {
                'source': 'rayban-meta',
                'timestamp': datetime.now().isoformat(),
                'auto_analyze': 'true'
            }
            
            # Send to Clawdbot
            response = requests.post(
                f"{self.gateway_url}/api/media/upload",
                files=files,
                data=data,
                headers=headers,
                timeout=30
            )
            
            if response.ok:
                result = response.json()
                print(f"✅ Sent to Clawdbot")
                
                if 'analysis' in result:
                    print(f"🔍 Analysis: {result['analysis']}")
                    self.speak(result['analysis'])
                
                return result
            else:
                print(f"❌ Upload failed: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error processing {file_path.name}: {e}")
    
    def speak(self, text):
        """Text-to-speech output"""
        try:
            # iOS Pythonista
            import speech
            speech.say(text)
        except ImportError:
            try:
                # Try system TTS
                os.system(f'say "{text}"' if os.uname().sysname == 'Darwin' else f'espeak "{text}"')
            except:
                print(f"🔊 {text}")

def main():
    """Run the bridge"""
    # Configuration
    GATEWAY_URL = os.getenv('CLAWDBOT_GATEWAY', 'http://192.168.1.100:8180')
    AUTH_TOKEN = os.getenv('CLAWDBOT_TOKEN', 'your-token-here')
    
    # Allow command line override
    import sys
    if len(sys.argv) > 1:
        GATEWAY_URL = sys.argv[1]
    if len(sys.argv) > 2:
        AUTH_TOKEN = sys.argv[2]
    
    # Start bridge
    bridge = MetaGlassesBridge(GATEWAY_URL, AUTH_TOKEN)
    bridge.monitor_photos()

if __name__ == '__main__':
    main()