#!/bin/sh
# MC API helper for Raven (Product Owner)
AGENT_TOKEN="WeWnFbK9IoknRjXFPGsV-xHlgGJkXZNcfgltKCQasFQ"
LOCAL_TOKEN="HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
MC_URL="http://host.docker.internal:8001"
BOARD="24394a90-a74e-479c-95e8-e5d24c7b4a40"

case "$1" in
  health)
    curl -s -m 10 "$MC_URL/health"
    ;;
  boards)
    curl -s -m 10 -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL/api/v1/agent/boards"
    ;;
  tasks|cards)
    BID="${2:-$BOARD}"
    curl -s -m 10 -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL/api/v1/agent/boards/$BID/tasks"
    ;;
  create-task|create-card)
    BID="${2:-$BOARD}"
    curl -s -m 10 -X POST -H "Authorization: Bearer $AGENT_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/agent/boards/$BID/tasks"
    ;;
  update-task|update-card)
    curl -s -m 10 -X PATCH -H "Authorization: Bearer $AGENT_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/agent/boards/$BOARD/tasks/$2"
    ;;
  comments)
    curl -s -m 10 -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL/api/v1/agent/boards/$BOARD/tasks/$2/comments"
    ;;
  add-comment)
    curl -s -m 10 -X POST -H "Authorization: Bearer $AGENT_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/agent/boards/$BOARD/tasks/$2/comments"
    ;;
  tags)
    BID="${2:-$BOARD}"
    curl -s -m 10 -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL/api/v1/agent/boards/$BID/tags"
    ;;
  memory)
    BID="${2:-$BOARD}"
    curl -s -m 10 -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL/api/v1/agent/boards/$BID/memory"
    ;;
  agents)
    curl -s -m 10 -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL/api/v1/agent/agents"
    ;;
  heartbeat)
    curl -s -m 10 -X POST -H "Authorization: Bearer $AGENT_TOKEN" -H "Content-Type: application/json" -d "$2" "$MC_URL/api/v1/agent/heartbeat"
    ;;
  activity)
    curl -s -m 10 -H "Authorization: Bearer $LOCAL_TOKEN" "$MC_URL/api/v1/activity"
    ;;
  *)
    M="${1:-GET}"; E="$2"; B="$3"
    if [ -n "$B" ]; then
      curl -s -m 10 -X "$M" -H "Authorization: Bearer $AGENT_TOKEN" -H "Content-Type: application/json" -d "$B" "$MC_URL$E"
    else
      curl -s -m 10 -X "$M" -H "Authorization: Bearer $AGENT_TOKEN" "$MC_URL$E"
    fi
    ;;
esac
