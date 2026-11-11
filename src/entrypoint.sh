#!/bin/sh
# TOS wrapper: Django needs a persistent SECRET_KEY; generate it once into the
# data volume instead of hardcoding it in the compose file.
set -u
set -e
SECRET_FILE=/home/nonroot/pdfding/db/.secret_key
if [ ! -s "$SECRET_FILE" ]; then
  head -c 48 /dev/urandom | base64 | tr -d '\n' > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"
fi
export SECRET_KEY="$(cat "$SECRET_FILE")"
exec ./bootstrap.sh
