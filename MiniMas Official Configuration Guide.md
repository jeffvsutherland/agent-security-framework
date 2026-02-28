# Complete OpenClaw Configuration Guide: Anthropic + MiniMax Dual Setup

Since ClawDBot hasn't been updated with native MiniMax support, you can still use both Anthropic and MiniMax together by configuring MiniMax as a custom provider with Anthropic as your primary model and MiniMax as a fallback. This guide provides complete step-by-step instructions.

## Understanding the Architecture

OpenClaw consists of two main components: the shell/frontend (your 2026.2.19 version) and the agent backend (ClawDBot v2026.1.24-3). The issue you're experiencing occurs because ClawDBot doesn't recognize the MiniMax model provider, even though the shell has the configuration option available. By manually adding MiniMax as a custom provider in your configuration file, you can bypass this limitation and use both Anthropic and MiniMax together.

The solution involves editing your OpenClaw configuration file directly to add MiniMax as a custom provider with the correct API endpoint and model definitions. This approach works because OpenClaw's configuration system allows you to extend the built-in model catalog with custom providers through the `models.providers` section.

## Configuration File Location and Structure

Your OpenClaw configuration is stored at `~/.openclaw/openclaw.json`. Before making any changes, you should first check if this file exists and back up your current configuration. The configuration uses JSON5 format, which is a superset of JSON that allows comments and relaxed syntax, making it more readable and maintainable.

To back up your existing configuration, run the following command in your terminal:

bash

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```

This creates a backup that you can restore if anything goes wrong during the configuration process.

## Complete Configuration for Anthropic Primary + MiniMax Fallback

Below is the complete configuration that sets up Anthropic Claude Opus 4.6 as your primary model with MiniMax M2.1 as the fallback. This configuration also includes both API keys and defines the model catalog for the `/model` command.

json

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-your-anthropic-api-key-here",
    "MINIMAX_API_KEY": "sk-your-minimax-api-key-here"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "minimax": {
        "baseUrl": "https://api.minimax.io/anthropic",
        "apiKey": "${MINIMAX_API_KEY}",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "MiniMax-M2.1",
            "name": "MiniMax M2.1",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 15,
              "output": 60,
              "cacheRead": 2,
              "cacheWrite": 10
            },
            "contextWindow": 200000,
            "maxTokens": 8192
          },
          {
            "id": "MiniMax-M2.1-lightning",
            "name": "MiniMax M2.1 Lightning",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 15,
              "output": 80,
              "cacheRead": 2,
              "cacheWrite": 10
            },
            "contextWindow": 200000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "models": {
        "anthropic/claude-opus-4-20250514": {
          "alias": "opus"
        },
        "anthropic/claude-sonnet-4-20250514": {
          "alias": "sonnet"
        },
        "minimax/MiniMax-M2.1": {
          "alias": "minimax"
        }
      },
      "model": {
        "primary": "anthropic/claude-opus-4-20250514",
        "fallbacks": ["minimax/MiniMax-M2.1"]
      }
    }
  }
}
```

This configuration accomplishes several important things. First, it adds the MiniMax provider with the Anthropic-compatible API endpoint, which is the recommended method for connecting to MiniMax services. Second, it defines the model pricing information for cost tracking, which helps OpenClaw calculate usage expenses accurately. Third, it establishes the fallback chain where if the primary Anthropic model fails or is unavailable, OpenClaw automatically switches to MiniMax M2.1.

## Alternative Configuration Using MiniMax M2.5

If you want to use the newer MiniMax M2.5 model instead of M2.1, you need to modify the model definition in the providers section. Note that M2.5 may require different pricing and context window values, so check the MiniMax documentation for the most current specifications.

json

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-your-anthropic-api-key-here",
    "MINIMAX_API_KEY": "sk-your-minimax-api-key-here"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "minimax": {
        "baseUrl": "https://api.minimax.io/anthropic",
        "apiKey": "${MINIMAX_API_KEY}",
        "api": "anthropic-messages",
        "models": [
          {
            "id": "MiniMax-M2.5",
            "name": "MiniMax M2.5",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 20,
              "output": 80,
              "cacheRead": 2,
              "cacheWrite": 10
            },
            "contextWindow": 200000,
            "maxTokens": 16384
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "models": {
        "anthropic/claude-opus-4-20250514": {
          "alias": "opus"
        },
        "minimax/MiniMax-M2.5": {
          "alias": "minimax"
        }
      },
      "model": {
        "primary": "anthropic/claude-opus-4-20250514",
        "fallbacks": ["minimax/MiniMax-M2.5"]
      }
    }
  }
}
```

The key difference in this configuration is the model ID changed from "MiniMax-M2.1" to "MiniMax-M2.5" and the maximum output tokens increased to 16384, reflecting the newer model's capabilities.

## Step-by-Step Implementation Guide

Now that you understand the configuration structure, follow these steps to implement the dual-provider setup on your system.

**Step 1: Verify Environment Variables**

Before editing your configuration file, ensure you have both API keys available. You can set them as environment variables in your shell profile to avoid hardcoding them in the configuration file. Add the following lines to your `~/.bashrc` or `~/.zshrc` file:

bash

```bash
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-api-key"
export MINIMAX_API_KEY="sk-your-minimax-api-key"
```

After adding these lines, reload your shell configuration:

bash

```bash
source ~/.bashrc  # for bash
# or
source ~/.zshrc   # for zsh
```

**Step 2: Create or Edit the Configuration File**

If you already have an `openclaw.json` file, read its contents first to understand your current setup:

bash

```bash
cat ~/.openclaw/openclaw.json
```

Then create or overwrite the file with the complete configuration provided above. Use a text editor like nano or vim:

bash

```bash
nano ~/.openclaw/openclaw.json
```

Paste the complete configuration and save the file.

**Step 3: Restart the OpenClaw Gateway**

After saving your configuration, you need to restart the OpenClaw gateway for the changes to take effect:

bash

```bash
openclaw gateway restart
```

Wait a moment for the gateway to fully restart, then verify that both models are recognized:

bash

```bash
openclaw models list
```

This command should now show both your Anthropic models and the MiniMax models in the available model list.

**Step 4: Verify the Configuration**

Test that the fallback mechanism works by checking the model status:

bash

```bash
openclaw models status --probe
```

This command probes each configured model to verify connectivity and authentication. If you see errors, the output will indicate which model is failing and why.

## Understanding the Fallback Mechanism

The fallback system in OpenClaw works by attempting to use the primary model first, and if it fails due to API errors, rate limiting, authentication issues, or timeouts, it automatically attempts to use the fallback models in order. This provides resilience against service interruptions and helps maintain continuous operation.

When a fallback is triggered, OpenClaw logs the event so you can monitor when your primary model fails. You can also manually switch between models using the `/model` command in your chat interface if you want to proactively use a different model for specific tasks.

The fallback configuration supports multiple models in sequence. If you want to add more fallback options, simply add them to the fallbacks array in your configuration:

json

```json
"model": {
  "primary": "anthropic/claude-opus-4-20250514",
  "fallbacks": [
    "anthropic/claude-sonnet-4-20250514",
    "minimax/MiniMax-M2.1"
  ]
}
```

This configuration first tries Opus, then falls back to Sonnet if Opus fails, and finally to MiniMax if both Anthropic models fail.

## Troubleshooting Common Issues

If you encounter issues after implementing this configuration, the following troubleshooting steps can help diagnose and resolve common problems.

**Issue: "Unknown model: minimax/MiniMax-M2.1"**

This error indicates that OpenClaw isn't recognizing the MiniMax provider. The most common cause is that the configuration file wasn't properly reloaded. First, verify that the MiniMax provider is properly defined in your configuration file. Then restart the gateway again:

bash

```bash
openclaw gateway restart
```

Wait at least 10 seconds for the gateway to fully initialize, then check the model list again.

**Issue: Authentication Failures**

If you see authentication errors, verify that your API keys are correctly set as environment variables and that they have the correct permissions. For MiniMax, ensure you have an API key with access to the M2.1 or M2.5 models. You can test your MiniMax API key directly using curl:

bash

```bash
curl -X POST "https://api.minimax.io/anthropic/v1/messages" \
  -H "Authorization: Bearer $MINIMAX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MiniMax-M2.1",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

A successful response indicates your API key is working correctly.

**Issue: Rate Limiting**

If you experience rate limiting, consider adjusting the fallback configuration to use models from different providers. You can also implement a delay between fallback attempts by configuring the retry behavior in the advanced settings.

## Using the Configuration with Different MiniMax Endpoints

Depending on your location and subscription type, you might need to use a different endpoint for MiniMax. The configuration above uses the global endpoint `https://api.minimax.io/anthropic`, but users in China should use the CN endpoint `https://api.minimaxi.com/anthropic`.

To change the endpoint, modify the `baseUrl` in your configuration:

For global users:

json

```json
"minimax": {
  "baseUrl": "https://api.minimax.io/anthropic",
  ...
}
```

For China-based users:

json

```json
"minimax": {
  "baseUrl": "https://api.minimaxi.com/anthropic",
  ...
}
```

## Summary

This configuration provides a complete solution for using both Anthropic and MiniMax in OpenClaw without requiring a ClawDBot update. The key points to remember are: use `models.mode: "merge"` to add MiniMax alongside built-in providers, configure the MiniMax provider with the Anthropic-compatible API endpoint, set up fallbacks in the agent configuration, and always restart the gateway after making configuration changes.

With this setup, you get the reliability of Anthropic's models as primary with the cost-effectiveness of MiniMax as a backup, ensuring your AI assistant remains available even when one provider experiences issues.