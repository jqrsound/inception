#!/bin/sh
set -e

if [ ! -d "/etc/ssl/private" ]; then
    mkdir -p /etc/ssl/private
fi

if [ ! -f /etc/ssl/certs/nginx.crt ]; then
    echo "Generating TLS certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx.key \
        -out /etc/ssl/certs/nginx.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"
    echo "TLS certificate created successfully."
fi

if [ -f /etc/nginx/nginx.conf ]; then
    sed -i "s|SERVER_NAME|${DOMAIN_NAME}|g" /etc/nginx/nginx.conf
    echo "server_name configured to match ${DOMAIN_NAME} in nginx.conf"
fi

echo "Container running"
exec "$@"
