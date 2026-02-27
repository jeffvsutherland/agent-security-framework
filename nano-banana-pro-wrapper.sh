#!/bin/bash
# ASF Security Wrapper for nano-banana-pro
# Place this in PATH before the actual skill

# Unset all sensitive environment variables
unset GEMINI_API_KEY
unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY
unset GROQ_API_KEY
unset TOGETHER_API_KEY
unset DEEPSEEK_API_KEY

# Call the actual Python script
python3 /app/skills/nano-banana-pro/scripts/generate_image.py "$@"
