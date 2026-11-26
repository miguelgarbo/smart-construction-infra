#!/bin/bash

set -Eeuo pipefail

BACKUP_DIR="/opt/backup_smart_construction"
S3_BUCKET="s3://smart-construction-backup/database"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.dump"

echo "Starting Backup Smart Construction database"

docker exec smart-construction-db-1 pg_dump -U smart_migrator -Fc smart_construction > "$BACKUP_FILE"

echo "Generated Backup: $BACKUP_FILE"

aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/sm_backup_$TIMESTAMP.dump"

echo "Backup sented to the pretty s3 bucket :)"

find "$BACKUP_DIR" -type f -name "backup_*.dump" -mtime +7 -delete
