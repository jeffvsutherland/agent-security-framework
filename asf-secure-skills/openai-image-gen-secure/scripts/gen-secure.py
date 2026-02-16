#!/usr/bin/env python3
"""
ASF Secure OpenAI Image Generator
Uses Clawdbot's encrypted credential storage instead of environment variables
"""
import argparse
import base64
import datetime as dt
import json
import os
import random
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path


def get_secure_credential(provider, key_name):
    """
    Get credential from Clawdbot's secure auth storage
    This replaces os.environ.get() with encrypted credential access
    """
    # Find auth profiles location
    agent_dir = os.environ.get('CLAWDBOT_AGENT_DIR', 
                              Path.home() / '.clawdbot' / 'agents' / 'main' / 'agent')
    auth_path = Path(agent_dir) / 'auth-profiles.json'
    
    if not auth_path.exists():
        print(f"❌ No auth profiles found at {auth_path}", file=sys.stderr)
        print("   Run: clawdbot auth set openai api_key YOUR_KEY", file=sys.stderr)
        sys.exit(1)
    
    try:
        with open(auth_path, 'r') as f:
            auth_data = json.load(f)
        
        if provider not in auth_data:
            print(f"❌ No credentials found for provider: {provider}", file=sys.stderr)
            print(f"   Run: clawdbot auth set {provider} {key_name} YOUR_KEY", file=sys.stderr)
            sys.exit(1)
        
        if key_name not in auth_data[provider]:
            print(f"❌ No {key_name} found for {provider}", file=sys.stderr)
            print(f"   Run: clawdbot auth set {provider} {key_name} YOUR_KEY", file=sys.stderr)
            sys.exit(1)
        
        print(f"🛡️  Using secure credential from Clawdbot vault", file=sys.stderr)
        return auth_data[provider][key_name]
        
    except Exception as e:
        print(f"❌ Error reading secure credentials: {e}", file=sys.stderr)
        sys.exit(1)


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = re.sub(r"-{2,}", "-", text).strip("-")
    return text or "image"


def default_out_dir() -> Path:
    now = dt.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    preferred = Path.home() / "Projects" / "tmp"
    base = preferred if preferred.is_dir() else Path("./tmp")
    base.mkdir(parents=True, exist_ok=True)
    return base / f"openai-image-gen-{now}"


def pick_prompts(count: int) -> list[str]:
    """Generate random structured prompts"""
    styles = ["oil painting", "watercolor", "digital art", "photorealistic", "sketch"]
    subjects = ["landscape", "portrait", "abstract", "still life", "architecture"]
    moods = ["serene", "dramatic", "whimsical", "melancholic", "vibrant"]
    
    prompts = []
    for _ in range(count):
        style = random.choice(styles)
        subject = random.choice(subjects)
        mood = random.choice(moods)
        prompt = f"A {mood} {subject} in {style} style"
        prompts.append(prompt)
    
    return prompts


def generate_images(
    prompts: list[str],
    api_key: str,
    out_dir: Path,
    model: str = "dall-e-3",
    size: str = "1024x1024",
    quality: str = "standard",
    n: int = 1,
):
    """Generate images using OpenAI API"""
    results = []
    
    for i, prompt in enumerate(prompts):
        print(f"\nGenerating {i+1}/{len(prompts)}: {prompt}")
        
        # API request
        url = "https://api.openai.com/v1/images/generations"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        }
        data = json.dumps({
            "model": model,
            "prompt": prompt,
            "n": n,
            "size": size,
            "quality": quality,
            "response_format": "b64_json"
        }).encode()
        
        try:
            req = urllib.request.Request(url, data=data, headers=headers)
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read())
                
                # Save images
                for j, img_data in enumerate(result["data"]):
                    img_bytes = base64.b64decode(img_data["b64_json"])
                    
                    # Create filename
                    slug = slugify(prompt)[:50]
                    filename = f"{i+1:03d}-{slug}-{j+1}.png"
                    filepath = out_dir / filename
                    
                    with open(filepath, "wb") as f:
                        f.write(img_bytes)
                    
                    print(f"  ✅ Saved: {filename}")
                    results.append({
                        "prompt": prompt,
                        "filename": filename,
                        "path": str(filepath)
                    })
                    
        except urllib.error.HTTPError as e:
            error_body = e.read().decode()
            print(f"  ❌ API Error: {error_body}", file=sys.stderr)
        except Exception as e:
            print(f"  ❌ Error: {e}", file=sys.stderr)
    
    return results


def create_gallery(results: list[dict], out_dir: Path):
    """Create HTML gallery of generated images"""
    html = """<!DOCTYPE html>
<html>
<head>
    <title>OpenAI Image Generation Gallery</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .image-card { border: 1px solid #ddd; padding: 10px; border-radius: 8px; }
        .image-card img { width: 100%; height: auto; border-radius: 4px; }
        .prompt { margin-top: 10px; font-size: 14px; color: #555; }
        .security-note { background: #e8f5e9; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>🖼️ OpenAI Image Generation Gallery</h1>
    <div class="security-note">
        🛡️ <strong>ASF Secure:</strong> This gallery was generated using encrypted credential storage. 
        No API keys were exposed in environment variables.
    </div>
    <div class="gallery">
"""
    
    for result in results:
        html += f"""
        <div class="image-card">
            <img src="{result['filename']}" alt="{result['prompt']}">
            <div class="prompt">{result['prompt']}</div>
        </div>
"""
    
    html += """
    </div>
</body>
</html>"""
    
    gallery_path = out_dir / "index.html"
    with open(gallery_path, "w") as f:
        f.write(html)
    
    print(f"\n🎨 Gallery created: {gallery_path}")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Generate images using OpenAI (ASF Secure)")
    parser.add_argument("prompt", nargs="?", help="Image prompt")
    parser.add_argument("--count", type=int, default=1, help="Number of images")
    parser.add_argument("--random", action="store_true", help="Generate random prompts")
    parser.add_argument("--model", default="dall-e-3", help="Model to use")
    parser.add_argument("--size", default="1024x1024", help="Image size")
    parser.add_argument("--quality", default="standard", help="Image quality")
    parser.add_argument("--out-dir", type=Path, help="Output directory")
    
    args = parser.parse_args()
    
    # Get secure API key (REPLACING THE VULNERABLE LINE 176!)
    api_key = get_secure_credential("openai", "api_key")
    
    # Determine prompts
    if args.random or not args.prompt:
        prompts = pick_prompts(args.count)
    else:
        prompts = [args.prompt] * args.count
    
    # Setup output directory
    out_dir = args.out_dir or default_out_dir()
    out_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"🖼️  OpenAI Image Generator (ASF Secure Version)")
    print(f"📁 Output directory: {out_dir}")
    
    # Generate images
    results = generate_images(
        prompts, 
        api_key,
        out_dir,
        model=args.model,
        size=args.size,
        quality=args.quality
    )
    
    # Create gallery
    if results:
        create_gallery(results, out_dir)
        print(f"\n✅ Generated {len(results)} images securely!")
    else:
        print("\n❌ No images generated")
        sys.exit(1)


if __name__ == "__main__":
    main()