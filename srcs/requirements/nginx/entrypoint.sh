#!/bin/sh
set -e

# FIX 1: Explicitly create the private key directory required by Alpine
if [ ! -d "/etc/ssl/private" ]; then
    mkdir -p /etc/ssl/private
fi

# Generate the self-signed TLS/SSL certificate using your .env DOMAIN_NAME
if [ ! -f /etc/ssl/certs/nginx.crt ]; then
    echo "Generating TLS certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx.key \
        -out /etc/ssl/certs/nginx.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"
    echo "TLS certificate created successfully."
fi

# FIX 2: Apply your domain placeholder directly into the main configuration file
# (Adjust this path if you specifically copied your file into a different layout)
if [ -f /etc/nginx/nginx.conf ]; then
    sed -i "s|SERVER_NAME|${DOMAIN_NAME}|g" /etc/nginx/nginx.conf
    echo "server_name configured to match ${DOMAIN_NAME} in nginx.conf"
fi

echo "Container running ✅"
exec nginx -g 'daemon off;'