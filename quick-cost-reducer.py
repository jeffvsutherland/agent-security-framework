#!/usr/bin/env python3
"""
Quick API Cost Reducer - Immediate entropy elimination
Configure all agents to use appropriate model tiers
"""
import json
import subprocess

# Model configurations by task type
MODEL_TIERS = {
    "heartbeat": {
        "model": "claude-3-haiku-20240307",
        "max_tokens": 200,
        "temperature": 0.1
    },
    "routine": {
        "model": "gpt-3.5-turbo",
        "max_tokens": 500,
        "temperature": 0.3
    },
    "standard": {
        "model": "claude-3-sonnet-20240229",
        "max_tokens": 2000,
        "temperature": 0.5
    },
    "complex": {
        "model": "claude-3-opus-20240229",
        "max_tokens": 4000,
        "temperature": 0.7
    }
}

# Agent task mappings
AGENT_TASKS = {
    "heartbeat_check": "heartbeat",
    "status_update": "heartbeat",
    "file_listing": "routine",
    "simple_query": "routine",
    "code_generation": "standard",
    "analysis": "standard",
    "architecture": "complex",
    "security_audit": "complex"
}

def estimate_daily_savings():
    """
    Calculate potential savings from model tiering
    """
    # Rough estimates of daily usage
    daily_calls = {
        "heartbeat": 144,  # 24 hours * 6 agents
        "routine": 200,
        "standard": 50,
        "complex": 10
    }
    
    # Cost per 1K tokens (approximate)
    old_cost_per_k = 0.015  # All using Opus
    new_costs_per_k = {
        "heartbeat": 0.00025,  # Haiku
        "routine": 0.0005,     # GPT-3.5
        "standard": 0.003,     # Sonnet
        "complex": 0.015       # Opus
    }
    
    # Average tokens per call
    avg_tokens = 1000
    
    # Calculate old cost (everything on Opus)
    total_calls = sum(daily_calls.values())
    old_daily_cost = (total_calls * avg_tokens / 1000) * old_cost_per_k
    
    # Calculate new cost (tiered)
    new_daily_cost = 0
    for tier, calls in daily_calls.items():
        cost = (calls * avg_tokens / 1000) * new_costs_per_k[tier]
        new_daily_cost += cost
    
    savings = old_daily_cost - new_daily_cost
    reduction = (savings / old_daily_cost) * 100
    
    print(f"💰 DAILY COST ANALYSIS")
    print(f"Old cost (all Opus): ${old_daily_cost:.2f}")
    print(f"New cost (tiered):   ${new_daily_cost:.2f}")
    print(f"Daily savings:       ${savings:.2f} ({reduction:.1f}% reduction)")
    print(f"Annual savings:      ${savings * 365:.2f}")
    
    return savings

def create_agent_config(agent_name, default_tier="routine"):
    """
    Create cost-optimized config for an agent
    """
    config = {
        "agent_name": agent_name,
        "default_model_tier": default_tier,
        "model_selection": {
            "rules": [
                {
                    "pattern": "heartbeat|status|ping",
                    "tier": "heartbeat"
                },
                {
                    "pattern": "list|check|simple",
                    "tier": "routine"
                },
                {
                    "pattern": "analyze|generate|create",
                    "tier": "standard"
                },
                {
                    "pattern": "architect|security|critical",
                    "tier": "complex"
                }
            ]
        },
        "cost_tracking": True,
        "batch_window": 300,  # 5 minutes
        "cache_ttl": 3600     # 1 hour
    }
    
    return config

def generate_team_configs():
    """
    Generate cost-optimized configs for all ASF agents
    """
    agents = [
        ("product-owner", "standard"),  # Raven needs more complex thinking
        ("main-agent", "standard"),
        ("sales-agent", "routine"),
        ("deploy-agent", "routine"),
        ("research-agent", "standard"),
        ("social-agent", "routine")
    ]
    
    configs = {}
    for agent_name, default_tier in agents:
        configs[agent_name] = create_agent_config(agent_name, default_tier)
    
    # Save configs
    with open("agent-cost-configs.json", "w") as f:
        json.dump(configs, f, indent=2)
    
    print(f"\n✅ Generated configs for {len(agents)} agents")
    print("📁 Saved to: agent-cost-configs.json")
    
    return configs

def main():
    print("🚀 API COST REDUCTION - IMMEDIATE ACTION")
    print("=" * 50)
    
    # Show potential savings
    savings = estimate_daily_savings()
    
    print("\n" + "=" * 50)
    print("📋 IMPLEMENTATION STEPS:")
    print("\n1. IMMEDIATE (Now):")
    print("   - Switch all heartbeats to Haiku")
    print("   - Route simple tasks to GPT-3.5")
    
    print("\n2. TODAY:")
    print("   - Deploy agent configs")
    print("   - Implement request batching")
    print("   - Enable response caching")
    
    print("\n3. THIS WEEK:")
    print("   - Set up local Ollama for zero-cost tasks")
    print("   - Implement conversation compression")
    print("   - Add real-time cost tracking")
    
    # Generate configs
    print("\n" + "=" * 50)
    configs = generate_team_configs()
    
    print("\n🎯 NEXT ACTIONS:")
    print("1. Review agent-cost-configs.json")
    print("2. Deploy to each agent's workspace")
    print("3. Monitor cost reduction in real-time")
    print(f"\n💡 Start saving ${savings:.2f}/day immediately!")

if __name__ == "__main__":
    main()