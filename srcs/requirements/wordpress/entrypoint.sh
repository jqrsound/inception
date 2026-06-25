#!/bin/sh
set -e

# 1. READ SECRETS ACCORDING TO OUR NEW SCHEME
DB_PASSWORD=$(cat /run/secrets/db_password)
# We read the separate credentials file for the WordPress Administrator account
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)

# 2. MOVE WORDPRESS FILES IF NOT ALREADY DONE
if [ ! -f /var/www/html/wp-login.php ]; then
    echo "Copying WordPress core files..."
    cp -r /tmp/wordpress/* /var/www/html/
    # Ensure hidden files or subdirectories are cleaned up carefully
    rm -rf /tmp/wordpress/*
fi

# 3. FIX PERMISSIONS FOR ALPINE (Alpine uses 'nginx:nginx' instead of 'www-data')
chown -R nginx:nginx /var/www/html
chmod -R 755 /var/www/html

# 4. WAIT FOR MARIADB TO BE READY
# (Uses $DB_HOST from your .env without port)
until mariadb -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" 2>/dev/null; do
    echo "Waiting for MariaDB at $DB_HOST..."
    sleep 2
done

# 5. CREATE CONFIGURATION FILE
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --path=/var/www/html \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root
    echo "wp-config.php created."
fi

# 6. INSTALL WORDPRESS CORE (Wrapped in a check so it only runs once)
if ! wp core is-installed --path=/var/www/html --allow-root; then
    echo "Installing WordPress core..."
    wp core install \
        --path=/var/www/html \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="admin@$DOMAIN_NAME" \
        --allow-root
    echo "WordPress installation completed."
fi

echo "Container running ✅"
# 7. RUN THE MODERN PHP-FPM PROCESS IN FOREGROUND
exec php-fpm84 -F