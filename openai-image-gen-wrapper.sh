#!/bin/bash
# ASF Security Wrapper for openai-image-gen
# Place this in PATH before the actual skill

# Unset all sensitive environment variables
unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY
unset GEMINI_API_KEY
unset GROQ_API_KEY
unset TOGETHER_API_KEY
unset DEEPSEEK_API_KEY

# Call the actual Python script
python3 /app/skills/openai-image-gen/scripts/gen.py "$@"
