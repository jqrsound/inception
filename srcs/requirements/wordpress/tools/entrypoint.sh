#!/bin/sh
set -e

if ! getent group nginx >/dev/null; then
    addgroup -S nginx
fi
if ! getent passwd nginx >/dev/null; then
    adduser -S nginx -G nginx
fi

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_SUBS_PASSWORD=$(cat /run/secrets/wp_subs_password)

if [ ! -f /var/www/html/wp-login.php ]; then
    echo "Copying WordPress core files..."
    cp -r /tmp/wordpress/* /var/www/html/
    rm -rf /tmp/wordpress/*
fi

chown -R nginx:nginx /var/www/html
chmod -R 755 /var/www/html

until mariadb -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -P 3306 -e "SELECT 1;" 2>/dev/null; do
    echo "Waiting for MariaDB at $DB_HOST..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --path=/var/www/html \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST:3306" \
        --allow-root
    echo "wp-config.php created."
fi

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

if ! wp user get "$WP_SUBS_USER" --path=/var/www/html --allow-root >/dev/null 2>&1; then
    wp user create "$WP_SUBS_USER" "$WP_SUBS_USER@$DOMAIN_NAME"\
        --role=subscriber \
        --user_pass="$WP_SUBS_PASSWORD" \
        --path=/var/www/html \
        --allow-root
fi

if ! wp plugin is-active redis-cache --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Configuring Redis cache integration..."

    wp config set WP_CACHE true --raw --path=/var/www/html --allow-root
    wp config set WP_REDIS_HOST "redis" --path=/var/www/html --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --path=/var/www/html --allow-root
    wp config set WP_CACHE_KEY_AUTH "inception_secret_salt" --path=/var/www/html --allow-root
    
    echo "Installing and activating Redis plugin files..."
    wp plugin install redis-cache --activate --path=/var/www/html --allow-root
    
    echo "Enabling Redis structural cache links..."
    wp redis enable --path=/var/www/html --allow-root

    chown -R nginx:nginx /var/www/html
fi

echo "Container running"
exec "$@"
