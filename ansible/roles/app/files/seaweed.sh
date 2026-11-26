#!/bin/bash

set -Eeuo pipefail

CONTAINERS=(
  "smart-construction-storage-1:/data"
  "smart-construction-private-storage-1:/data"
)

BACKUP_DIR="/opt/backup_smart_construction"
S3_BUCKET="s3://smart-construction-backup/seaweedfs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FAILED=0

mkdir -p "$BACKUP_DIR"

for ITEM in "${CONTAINERS[@]}"; do
  CONTAINER="${ITEM%%:*}"
  DATA_DIR="${ITEM#*:}"

  NAME="${CONTAINER#smart-construction-}"
  NAME="${NAME%-1}"

  BACKUP_FILE="$BACKUP_DIR/seaweedfs_${NAME}_$TIMESTAMP.tar.gz"

  echo "Starting Backup Smart Construction SeaweedFS: $NAME"

  if ! docker exec "$CONTAINER" tar -czf - -C "$DATA_DIR" . > "$BACKUP_FILE"; then
    rm -f "$BACKUP_FILE"
    echo "Backup failed for $NAME, partial file removed" >&2
    FAILED=$((FAILED + 1))
    continue
  fi

  echo "Generated Backup: $BACKUP_FILE"

  if ! aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/$NAME/sm_seaweedfs_${NAME}_$TIMESTAMP.tar.gz"; then
    echo "Upload failed for $NAME (local file kept: $BACKUP_FILE)" >&2
    FAILED=$((FAILED + 1))
    continue
  fi

  echo "Backup $NAME sent to the pretty s3 bucket :)"
done

find "$BACKUP_DIR" -type f -name "seaweedfs_*.tar.gz" -mtime +7 -delete

if [ "$FAILED" -gt 0 ]; then
  echo "$FAILED backup(s) failed" >&2
  exit 1
fi