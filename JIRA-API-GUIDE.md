# Jira API Access Guide for Raven (Agent Saturday)

## Quick Start

### Credentials
```
JIRA_URL: https://frequencyfoundation.atlassian.net
JIRA_USER: jeff.sutherland@gmail.com
JIRA_API_TOKEN: ATATT3xFfGF0khSabkTKRWmFCJ2ft6E-Mj_DpPxJEY-J3iccP6zn2ofP0yvApuT5C9L29xAHjEVOAKDjKXOBUA2U3ugzHoIK5b-FpLISFRwTiC4iRvqpQ6NHdv8cUmP-k0xV85WDoF8UBx5Z-X8tLiCL4pP-72iIOGrIlYCZ9iFigyuu4U-wN08=8086D014
```

### Authentication
Use curl with Basic Auth:
```bash
curl -u "jeff.sutherland@gmail.com:ATATT3xFfGF0khSabkTKRWmFCJ2ft6E-Mj_DpPxJEY-J3iccP6zn2ofP0yvApuT5C9L29xAHjEVOAKDjKXOBUA2U3ugzHoIK5b-FpLISFRwTiC4iRvqpQ6NHdv8cUmP-k0xV85WDoF8UBx5Z-X8tLiCL4pP-72iIOGrIlYCZ9iFigyuu4U-wN08=8086D014" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/..."
```

---

## Available Projects

| Key | Name |
|-----|------|
| ASF | Agent Security Framework |
| FF | Frequency Foundation |
| JMS | JVS Management Scrum |

---

## Common API Endpoints

### Get Current User
```bash
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/myself"
```

### List Projects
```bash
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/project"
```

### Search Issues (JQL)
```bash
# All issues in FF project
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/search/jql?jql=project=FF"

# Issues assigned to you
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/search/jql?jql=assignee=currentUser()"

# Issues in a specific sprint (FF Sprint 211)
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/search/jql?jql=Sprint='FF Sprint 211'"
```

### Get Specific Issue
```bash
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/issue/FF-1009"
```

### Update Issue Status
```bash
# Get available transitions
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/issue/FF-1009/transitions"

# Transition to "Done"
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"transition":{"id":"31"}}' \
  "https://frequencyfoundation.atlassian.net/rest/api/3/issue/FF-1009/transitions"
```

### Add Comment
```bash
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"body":{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"Comment from Raven"}]}]}}' \
  "https://frequencyfoundation.atlassian.net/rest/api/3/issue/FF-1009/comment"
```

### Assign Issue
```bash
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{"accountId":"70121:14326677-ddb5-47ab-bd97-8a2a5d57587f"}' \
  "https://frequencyfoundation.atlassian.net/rest/api/3/issue/FF-1009/assignee"
```

---

## Python Example

```python
import requests
from requests.auth import HTTPBasicAuth

JIRA_URL = "https://frequencyfoundation.atlassian.net"
USER = "jeff.sutherland@gmail.com"
TOKEN = "ATATT3xFfGF0khSabkTKRWmFCJ2ft6E-Mj_DpPxJEY-J3iccP6zn2ofP0yvApuT5C9L29xAHjEVOAKDjKXOBUA2U3ugzHoIK5b-FpLISFRwTiC4iRvqpQ6NHdv8cUmP-k0xV85WDoF8UBx5Z-X8tLiCL4pP-72iIOGrIlYCZ9iFigyuu4U-wN08=8086D014"

auth = HTTPBasicAuth(USER, TOKEN)
headers = {"Content-Type": "application/json"}

# Search issues
def search_issues(jql):
    url = f"{JIRA_URL}/rest/api/3/search/jql"
    params = {"jql": jql, "maxResults": 50}
    response = requests.get(url, auth=auth, headers=headers, params=params)
    return response.json()

# Get issues from FF project
issues = search_issues("project=FF ORDER BY created DESC")
for issue in issues.get('issues', []):
    print(f"{issue['key']}")
```

---

## Important Notes

1. **API Format**: Use `/rest/api/3/search/jql` (not `/rest/api/3/search`)
2. **Token Expiry**: If auth fails, token may have expired - generate new at:
   https://id.atlassian.com/manage-profile/security/api-tokens
3. **Your Account ID**: `70121:14326677-ddb5-47ab-bd97-8a2a5d57587f`

---

## Board/Sprint Access

### Get Boards
```bash
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/api/3/board?projectKey=FF"
```

### Get Sprints
```bash
# Board ID 1 = FF board
curl -s -u "jeff.sutherland@gmail.com:[TOKEN]" \
  "https://frequencyfoundation.atlassian.net/rest/agile/1/board/1/sprint?state=active"
```

---

*Last updated: 2026-02-24*
*For Raven / Agent Saturday*
