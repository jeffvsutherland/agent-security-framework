#!/bin/bash
# Test wrapper for locally installed Oracle with security fix
unset OPENAI_API_KEY ANTHROPIC_API_KEY GEMINI_API_KEY
exec /workspace/node_modules/.bin/oracle "$@"