#!/bin/sh
set -e

DB_PATH="/app/data/kuma.db"

# Check if Uptime Kuma has ever been initialized
if [ ! -f "$DB_PATH" ]; then
    echo "Initializing fresh Uptime Kuma database..."

    # 1. Read admin password from the Docker secret mapping
    KUMA_ADMIN_USER="admin"
    KUMA_ADMIN_PASS=$(cat /run/secrets/kuma_password)

    # 2. Use Node.js natively to generate a secure bcrypt hash of your secret
    # (Uptime Kuma utilizes standard bcrypt with 10 salt rounds)
    HASHED_PASS=$(node -e "
        const bcrypt = require('bcryptjs');
        console.log(bcrypt.hashSync('$KUMA_ADMIN_PASS', 10));
    ")

    # 3. Setup SQLite table scheme and securely inject your admin credentials
    # This skips the manual "Create Account" setup wizard screen entirely!
    node -e "
        const Database = require('better-sqlite3');
        const db = new Database('$DB_PATH');
        
        // Create user table structure if missing
        db.exec(\`
            CREATE TABLE IF NOT EXISTS user (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE,
                password TEXT,
                active INTEGER DEFAULT 1
            );
        \`);
        
        // Inject user account secure parameters
        const stmt = db.prepare('INSERT INTO user (username, password) VALUES (?, ?)');
        stmt.run('$KUMA_ADMIN_USER', '$HASHED_PASS');
        db.close();
    "
    echo "Admin credentials successfully created from secrets! 🔒"
fi

# Hand off execution to the primary Uptime Kuma server daemon process
exec node server/server.js