#!/bin/sh
# Daily pg_dump of both databases (app and Rivet engine) to R2, then sleep a day.
set -eu
export RCLONE_CONFIG_R2_TYPE=s3 RCLONE_CONFIG_R2_PROVIDER=Cloudflare
export RCLONE_CONFIG_R2_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID" RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export RCLONE_CONFIG_R2_ENDPOINT="https://$R2_ACCOUNT_ID.r2.cloudflarestorage.com"
export PGHOST=postgres PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD"

while true; do
  stamp=$(date -u +%Y-%m-%dT%H%M%SZ)
  for db in app rivet; do
    pg_dump -Fc "$db" > "/tmp/$db.dump"
    rclone copyto "/tmp/$db.dump" "r2:$R2_BUCKET/backups/$stamp/$db.dump"
    rm "/tmp/$db.dump"
  done
  echo "backup $stamp done"
  sleep 86400
done
