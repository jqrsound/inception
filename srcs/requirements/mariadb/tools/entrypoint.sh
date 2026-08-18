#!/bin/sh
set -e

if [ ! -d "/var/run/mysqld" ]; then
    mkdir -p /var/run/mysqld
    chown -R mysql:mysql /var/run/mysqld
fi

chown -R mysql:mysql /var/lib/mysql

MARKER_FILE="/var/lib/mysql/.db_initialized"

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -f "$MARKER_FILE" ]; then
    echo "Marker file does not exist"
    echo "Initializing mariadb..."
    
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql

    mysqld_safe --datadir=/var/lib/mysql --user=mysql &
    pid="$!"

    while [ ! -S /var/run/mysqld/mysqld.sock ]; do
        echo "Waiting for UNIX socket..."
        sleep 2
    done

    mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    touch "$MARKER_FILE"

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
    echo "Initialization completed"
fi

echo "Container running"
exec "$@"
