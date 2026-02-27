#!/bin/bash
# Wrapper script for Jira API access with secure token handling

# Store the API token securely (you can also use keychain)
export JIRA_API_TOKEN="ATATT3xFfGF0khSabkTKRWmFCJ2ft6E-Mj_DpPxJEY-J3iccP6zn2ofP0yvApuT5C9L29xAHjEVOAKDjKXOBUA2U3ugzHoIK5b-FpLISFRwTiC4iRvqpQ6NHdv8cUmP-k0xV85WDoF8UBx5Z-X8tLiCL4pP-72iIOGrIlYCZ9iFigyuu4U-wN08=8086D014"

# Suppress SSL warnings
export PYTHONWARNINGS="ignore:Unverified HTTPS request"

# Run the Python script with all arguments
python3 jira-api-access.py "$@" 2>&1 | grep -v "NotOpenSSLWarning"