#!/bin/sh
set -e

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

if ! getent group ps2smb >/dev/null 2>&1; then
    addgroup -g "$PGID" ps2smb
fi

if ! getent passwd ps2smb >/dev/null 2>&1; then
    adduser -D -H -u "$PUID" -G ps2smb -s /sbin/nologin ps2smb
fi

mkdir -p /games
chown -R ps2smb:ps2smb /games

mkdir -p /var/log/samba
chown -R ps2smb:ps2smb /var/log/samba

exec smbd --foreground --no-process-group --debug-stdout
