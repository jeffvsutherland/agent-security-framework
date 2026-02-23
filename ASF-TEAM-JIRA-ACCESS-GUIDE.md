# ASF Team Jira Access Guide

## 🔧 Critical Setup for Automated Jira Access

### Prerequisites
1. **JIRA_API_TOKEN** environment variable must be set
2. Access to ASF project in Jira
3. Bash/Zsh shell with jq installed

### Quick Setup (One-Time)

```bash
# 1. Run the setup script
./setup-team-jira-access.sh

# 2. Add to your shell profile (~/.zshrc or ~/.bashrc):
export JIRA_API_TOKEN='ATATT3xFfGF07G0XrbrqhwiHLuz-oLFDQEcVHMPMRiIjJtzbUvJKl84zsLt8EvGH20XSkh73VSEwCR4AdZwIpji-KYHIgV7XhJUN0zyZLRVE0fhRtkX4fjzOMQNac0uHXf4c87BhmYikS73aYfUuBcPNEZ2ZsYjbxhUnEO5CLRLVvnw43qbfCyI=E6A8EB87'

# 3. Source the automation functions
source ./jira-automation.sh
```

### Available Automation Commands

#### 1. Create a Story
```bash
jira_create_story "Story Title" "Description" 8 "" "High"
# Parameters: title, description, points, assignee (optional), priority
```

#### 2. Update Story Status
```bash
jira_transition_story "ASF-21" "In Progress"
# Moves story to new status
```

#### 3. Add Comment
```bash
jira_add_comment "ASF-21" "Daily update: Completed API authentication module"
# Adds comment to story for daily standups
```

#### 4. List Stories
```bash
jira_list_stories              # All ASF stories
jira_list_stories "To Do"      # Filter by status
jira_list_stories "In Progress"
```

### Create All Sprint 2 Stories at Once
```bash
./create-asf-sprint2-stories-automated.sh
```

## 📱 Agent Integration

Each agent can use these functions in their workflow:

### For Daily Standups
```bash
# Post your daily update
jira_add_comment "ASF-21" "📊 Yesterday: Setup API framework
🎯 Today: Implement authentication endpoints
🚧 Blockers: Need Research Agent's ML model specs
🤝 Dependencies: Waiting on ASF-23 interface definition"
```

### For Status Updates
```bash
# When starting work
jira_transition_story "ASF-21" "In Progress"

# When completing work
jira_transition_story "ASF-21" "Done"
```

## 🔐 Security Notes

1. **Never commit API tokens** to git
2. Each agent should have their own API token (when possible)
3. Tokens should be stored in environment variables
4. Use read-only tokens where appropriate

## 🚀 Automation Benefits

1. **No manual Jira UI needed** - Everything via command line
2. **Scriptable workflows** - Agents can automate updates
3. **Consistent formatting** - Structured data entry
4. **Fast bulk operations** - Create many stories at once
5. **Integration ready** - Can be called from any script/agent

## 📊 Sprint 2 Stories Ready to Create

Total: 10 stories, 67 points

| Story | Title | Points | Assignee |
|-------|-------|--------|----------|
| ASF-21 | Cross-Platform Integration API | 13 | Deploy Agent |
| ASF-22 | Enterprise Dashboard | 8 | Deploy + Research |
| ASF-23 | Advanced Detection Algorithm | 8 | Research Agent |
| ASF-24 | Competitive Intelligence | 5 | Research Agent |
| ASF-25 | Enterprise Sales Package | 8 | Sales Agent |
| ASF-26 | Partnership Program | 5 | Sales Agent |
| ASF-27 | Community Growth | 5 | Social Agent |
| ASF-28 | Thought Leadership | 5 | Social + PO |
| ASF-29 | Product Management | 3 | Product Owner |
| ASF-30 | QA & Operations | 5 | Deploy + PO |

## ⚠️ Known Issues & Solutions

### Auth Token Error
```
❌ ERROR: JIRA_API_TOKEN environment variable not found!
```
**Solution:** Add the export line to your shell profile

### API Version Error
```
The requested API has been removed. Please migrate to the /rest/api/3
```
**Solution:** Our scripts already use API v3

### Permission Denied
```
Failed to create story (HTTP 403)
```
**Solution:** Verify you have create permissions in ASF project

## 🎯 Next Steps

1. **Test the automation** with a simple list command
2. **Create Sprint 2 stories** using the bulk script
3. **Share with agents** so they can automate their updates
4. **Monitor usage** and improve based on feedback

This automation enables the entire ASF team to work efficiently with Jira without manual UI interaction!