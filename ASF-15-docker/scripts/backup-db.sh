#!/bin/bash

# ASF Database Backup Script

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/asf_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "Creating database backup..."

# Perform backup
docker-compose exec -T postgres pg_dump -U asf asf_db > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "Backup completed: $BACKUP_FILE"
    
    # Compress the backup
    gzip $BACKUP_FILE
    echo "Backup compressed: ${BACKUP_FILE}.gz"
    
    # Keep only last 7 backups
    ls -t ${BACKUP_DIR}/asf_backup_*.sql.gz | tail -n +8 | xargs -r rm
    echo "Old backups cleaned up (keeping last 7)"
else
    echo "Backup failed!"
    exit 1
fi