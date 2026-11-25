#!/bin/sh
# TOS wrapper for the upstream PdfDing image.
#
# 1. Django needs a persistent SECRET_KEY. Generate it once into the data
#    volume instead of hardcoding it in the compose file.
# 2. The platform creates the bind-mount roots with the default 0755 mode. The
#    database and the uploaded PDFs must not be readable by other local users,
#    so tighten the two data directories on every start (this also repairs the
#    permissions of an install upgraded from an older package).
set -u
set -e

umask 077

DATA_DIR=/home/nonroot/pdfding
SECRET_FILE="$DATA_DIR/db/.secret_key"

mkdir -p "$DATA_DIR/db" "$DATA_DIR/media"

if [ ! -s "$SECRET_FILE" ]; then
  head -c 48 /dev/urandom | base64 | tr -d '\n' > "$SECRET_FILE"
fi
chmod 600 "$SECRET_FILE"

# S11: 0700 directories and 0600 database files, owned by the app user only.
# Ignore failures on mounts this process does not own (staging / foreign uid):
# the container still starts, and the platform-owned directory is reported by
# the installer instead of being silently left world-readable.
for d in "$DATA_DIR/db" "$DATA_DIR/media"; do
  [ -d "$d" ] && chmod 700 "$d" 2>/dev/null || true
done
find "$DATA_DIR/db" -maxdepth 1 -type f -exec chmod 600 {} + 2>/dev/null || true

export SECRET_KEY="$(cat "$SECRET_FILE")"

# Upstream 1.15.0 runs ./entrypoint.sh (1.7.2 used ./bootstrap.sh).
exec ./entrypoint.sh
