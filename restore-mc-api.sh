#!/bin/sh
# Run inside openclaw-gateway container to restore mc-api if missing
# Add to container entrypoint or run after recreation
if [ ! -f /usr/local/bin/mc-api ] && [ -f /workspace/.mc-api-backup ]; then
    cp /workspace/.mc-api-backup /usr/local/bin/mc-api
    chmod +x /usr/local/bin/mc-api
    echo "mc-api restored from backup"
fi

