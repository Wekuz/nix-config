#!/bin/bash

# This script requires root privileges and the existance of LOG_DIR and 

set -Eeuo pipefail
shopt -s failglob

GPG_RECIP="wekuz@duck.com"

DATA_DIR="/var/lib/vaultwarden/data"
BACKUP_DIR="$(mktemp -d /tmp/vw-backup.XXXXXX)"
DB_FILE="$BACKUP_DIR/db.sqlite3"
TAR_FILE="$BACKUP_DIR/vw-backup.tar.zst"
GPG_FILE="$TAR_FILE.gpg"

LOG_DIR="/var/log/vaultwarden"
LOG_FILE="$LOG_DIR/backup.log"
STATUS_FILE="/var/lib/glance/assets/vw-backup.json"

exec >>"$LOG_FILE" 2>&1

write_status() {
    local status="$1"
    local error_msg="${2:-null}"
    local last_success="${3:-null}"
    local size_bytes="${4:-null}"

    cat >"$STATUS_FILE" <<EOF
{
  "status": "$status",
  "last_run": "$(date -u +%d/%m/%y-%H:%M)",
  "last_success": "$last_success",
  "size_bytes": $size_bytes,
  "error": $error_msg
}
EOF
}

echo "===== Backup started at $(date -u +%d/%m/%y-%H:%M) ====="

cleanup() {
  rm -rf "$BACKUP_DIR"
}
trap cleanup EXIT

failure() {
  local err_msg="Command \"$BASH_COMMAND\" failed at line $LINENO"
  echo "!!!!! BACKUP FAILED at $(date -u +%d/%m/%y-%H:%M) with error: $err_msg !!!!!"
  write_status "failed" "\"$err_msg\"" "$(cat "$STATUS_FILE" | jq -r '.last_success')" null
}
trap failure ERR

log() {
    echo "[$(date -u +%d/%m/%y-%H:%M)] $*"
}



log "Starting SQLite DB backup..."
sqlite3 "$DATA_DIR/db.sqlite3" ".backup '$DB_FILE'"
log "SQLite DB backup completed."

log "Creating archive..."
tar -I "zstd -12" -cf "$TAR_FILE" "$DB_FILE" "$DATA_DIR/attachments" "$DATA_DIR"/rsa_key*
log "Archive created."

log "Encrypting backup with GPG..."
gpg --batch --yes -e -r "$GPG_RECIP" "$TAR_FILE"
log "Encryption completed."

log "Uploading backup..."
rclone sync "$GPG_FILE" backblaze:backups-wekuz
log "Upload completed."

write_status "success" null "$(date -u --rfc-3339=seconds)" "$(stat -c%s '$GPG_FILE')"

echo "===== Backup completed successfully at $(date -u +%d/%m/%y-%H:%M) ====="
