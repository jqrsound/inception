#!/bin/sh
set -e

if ! getent group nginx >/dev/null; then
    addgroup -S nginx
fi
if ! getent passwd nginx >/dev/null; then
    adduser -S nginx -G nginx
fi

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

# -------------------------------------------------------------------------
# 🚀 AUTOMATING REDIS BONUS (Point 3 & 4)
# -------------------------------------------------------------------------
# We wrap this in a conditional check to ensure we only run configuration
# routines if the object-cache plugin isn't fully initialized yet.
if ! wp plugin is-active redis-cache --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Configuring Redis cache integration..."
    
    # Inject the definitions right into your generated wp-config.php file
    wp config set WP_CACHE true --raw --path=/var/www/html --allow-root
    wp config set WP_REDIS_HOST "redis" --path=/var/www/html --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --path=/var/www/html --allow-root
    wp config set WP_CACHE_KEY_AUTH "inception_secret_salt" --path=/var/www/html --allow-root
    
    echo "Installing and activating Redis plugin files..."
    wp plugin install redis-cache --activate --path=/var/www/html --allow-root
    
    echo "Enabling Redis structural cache links..."
    wp redis enable --path=/var/www/html --allow-root
    
    # Re-apply ownership so the web server can read the newly generated drop-in files
    chown -R nginx:nginx /var/www/html
fi

echo "Container running"
# 7. RUN THE MODERN PHP-FPM PROCESS IN FOREGROUND
exec php-fpm84 -F