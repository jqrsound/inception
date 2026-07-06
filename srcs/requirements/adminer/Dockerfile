FROM alpine:3.23

RUN apk add --no-cache \
    php84 \
    php84-session \
    php84-mysqli \
    wget

WORKDIR /var/www/html

RUN wget https://github.com/vrana/adminer/releases/download/v5.4.2/adminer-5.4.2.php -O index.php

EXPOSE 8080

CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
