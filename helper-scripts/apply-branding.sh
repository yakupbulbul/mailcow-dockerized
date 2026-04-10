#!/bin/bash
# apply-branding.sh - Bootstrap branding assets into Mailcow Redis

MAILCOW_PATH="/root/mailcow-dockerized"
LOGO_SRC="$MAILCOW_PATH/data/web/branding/logo.png"

# Read Redis password from mailcow.conf
REDISPASS=$(grep "^REDISPASS=" "$MAILCOW_PATH/mailcow.conf" | cut -d= -f2)

if [ -z "$REDISPASS" ]; then
    echo "Error: Could not find REDISPASS in mailcow.conf"
    exit 1
fi

if [ ! -f "$LOGO_SRC" ]; then
    echo "Error: Logo source not found at $LOGO_SRC"
    exit 1
fi

echo "Encoding logo..."
BASE64_LOGO=$(base64 -w 0 "$LOGO_SRC")
REDIS_VALUE="data:image/png;base64,$BASE64_LOGO"

echo "Applying branding to Mailcow Redis via stdin..."

# Inject into Redis using stdin to avoid 'Argument list too long' errors
echo -n "$REDIS_VALUE" | docker compose exec -T redis-mailcow redis-cli -a "$REDISPASS" -x SET MAIN_LOGO
echo -n "$REDIS_VALUE" | docker compose exec -T redis-mailcow redis-cli -a "$REDISPASS" -x SET MAIN_LOGO_DARK

if [ $? -eq 0 ]; then
    echo "Success! Scenarix branding applied to Mailcow UI."
    echo "Note: You may need to clear your browser cache to see the changes."
else
    echo "Error: Failed to apply branding to Redis."
    exit 1
fi
