#!/bin/sh
set -e

DB_PATH="/app/data/kuma.db"

# 1. Check if this is the absolute first time booting up
if [ ! -f "$DB_PATH" ]; then
    echo "First time launch detected. Letting Uptime Kuma generate schema..."
    
    # Run the server in the background briefly so it constructs kuma.db
    node server/server.js &
    KUMA_PID=$!
    
    # Loop and wait until the database file is physically created on disk
    until [ -f "$DB_PATH" ]; do
        sleep 1
    done
    echo "Database schema generated successfully."
    
    # Give it one extra second to finish executing setup tasks, then stop it
    sleep 2
    kill $KUMA_PID
    wait $KUMA_PID 2>/dev/null || true

    echo "Provisioning automated admin credentials..."

    # 2. Extract password from your Docker secret asset
    KUMA_ADMIN_USER="admin"
    KUMA_ADMIN_PASS=$(cat /run/secrets/kuma_password)

    # 3. Generate the bcrypt hash using the native 'bcryptjs' already inside node_modules
    HASHED_PASS=$(node -e "
        const bcrypt = require('./node_modules/bcryptjs');
        console.log(bcrypt.hashSync('$KUMA_ADMIN_PASS', 10));
    ")

    # 4. Use native Alpine sqlite3 tool to safely insert the admin record
    sqlite3 "$DB_PATH" "INSERT INTO user (username, password, active) VALUES ('$KUMA_ADMIN_USER', '$HASHED_PASS', 1);"
    
    echo "Admin credentials injected successfully! 🔒"
fi

# 5. Hand execution over to primary Uptime Kuma server daemon process
echo "Starting Uptime Kuma Production Stack... 🚀"
exec node server/server.js
