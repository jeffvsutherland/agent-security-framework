#!/bin/bash

# Source the automation functions
source ./jira-automation.sh || exit 1

echo "🚀 Creating ASF Sprint 2 Stories"
echo "================================"

# Story details from team estimates
declare -a stories=(
    "ASF-21|Cross-Platform Integration API|13|Deploy Agent|High|Create enterprise-ready API for multi-platform ASF integration"
    "ASF-22|Enterprise Dashboard|8|Deploy Agent|Medium|Build enterprise dashboard for agent monitoring"
    "ASF-23|Advanced Detection Algorithm|8|Research Agent|High|Machine learning for fake agent detection"
    "ASF-24|Competitive Intelligence|5|Research Agent|Medium|Monitor fake agent threat landscape"
    "ASF-25|Enterprise Sales Package|8|Sales Agent|High|Create comprehensive enterprise sales materials"
    "ASF-26|Partnership & Integration Program|5|Sales Agent|Medium|Build reseller and platform partnership network"
    "ASF-27|Community Growth & Advocacy|5|Social Agent|High|Grow from 0 to 20+ beta testers"
    "ASF-28|Thought Leadership Campaign|5|Social Agent|Medium|Establish ASF as industry thought leader"
    "ASF-29|Product Roadmap & Sprint Management|3|Agent Saturday|High|Strategic product management and coordination"
    "ASF-30|QA & Operations|5|Deploy Agent|Medium|Quality assurance and operational excellence"
)

# Create each story
for story in "${stories[@]}"; do
    IFS='|' read -r key title points assignee priority description <<< "$story"
    echo ""
    echo "Creating $key..."
    jira_create_story "$title" "$description" "$points" "" "$priority"
    sleep 1  # Rate limiting
done

echo ""
echo "✅ Sprint 2 story creation complete!"
echo ""
echo "Next steps:"
echo "1. Assign stories to specific agent account IDs"
echo "2. Add stories to Sprint 2"
echo "3. Send kickoff messages to agents"
