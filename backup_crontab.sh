#!/bin/bash
set -euo pipefail

CONTAINER="ceproject-db-1"
DB="openproject"
USER="postgres"
BACKUP_DIR="/data/ceproject/NAS-backup"
RETENTION_DAYS=7

set -a
source /data/ceproject/.env
set +a

DATE="$(date +'%Y-%m-%d_%H-%M-%S')"
OUT="${BACKUP_DIR}/${DB}_${DATE}.sql.gz"
TMP="${OUT}.tmp"

mkdir -p "$BACKUP_DIR"

docker exec -i \
  -e PGPASSWORD="${POSTGRES_PASSWORD}" \
  "$CONTAINER" \
  pg_dump -U "$USER" "$DB" \
  | gzip -c > "$TMP"

mv "$TMP" "$OUT"

# Delete after 7 days
find "$BACKUP_DIR" -type f -name "${DB}_*.sql.gz" -mtime +"$RETENTION_DAYS" -delete


