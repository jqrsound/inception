FROM alpine:3.23

# Install PHP 8.4 core and the MySQL extension Adminer needs to talk to MariaDB
RUN apk add --no-cache \
    php84 \
    php84-session \
    php84-mysqli \
    wget

# Create a working directory for our web app
WORKDIR /var/www/html

# Download the Adminer file and name it index.php right away
RUN wget https://github.com/vrana/adminer/releases/download/v5.4.2/adminer-5.4.2.php -O index.php

# Expose the port internal to the Docker network
EXPOSE 8080

# Run the PHP built-in development server directly
CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
