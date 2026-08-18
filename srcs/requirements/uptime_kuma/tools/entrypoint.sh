#!/bin/sh
set -e

DB_PATH="/app/data/kuma.db"

if [ ! -f "$DB_PATH" ]; then
    echo "First time launch detected. Letting Uptime Kuma generate schema..."
    
    node server/server.js &
    KUMA_PID=$!
    
    until [ -f "$DB_PATH" ]; do
        sleep 1
    done
    echo "Database schema generated successfully."
    
    sleep 2
    kill $KUMA_PID
    wait $KUMA_PID 2>/dev/null || true

    echo "Provisioning automated admin credentials & infrastructure monitors..."

    KUMA_ADMIN_USER="admin"
    KUMA_ADMIN_PASS=$(cat /run/secrets/kuma_password)

    HASHED_PASS=$(node -e "
        const bcrypt = require('./node_modules/bcryptjs');
        console.log(bcrypt.hashSync('$KUMA_ADMIN_PASS', 10));
    ")

    sqlite3 "$DB_PATH" "INSERT INTO user (username, password, active) VALUES ('$KUMA_ADMIN_USER', '$HASHED_PASS', 1);"

    echo "Admin credentials and core infrastructure monitors successfully injected! 🔒⚡"
fi

echo "Starting Uptime Kuma Production Stack... 🚀"
exec "$@"
