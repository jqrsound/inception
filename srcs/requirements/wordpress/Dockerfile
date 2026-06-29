FROM alpine:3.23

ARG WP_VERSION=6.7

RUN apk add --no-cache \
    php84 \
    php84-fpm \
    php84-mysqli \
    php84-phar \
    php84-iconv \
    php84-curl \
    php84-openssl \
    php84-mbstring \
    php84-tokenizer \
    mariadb-client \
    wget \
    unzip

RUN addgroup -S nginx && adduser -S nginx -G nginx

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html

RUN wget https://wordpress.org/wordpress-${WP_VERSION}.zip && \
    unzip wordpress-${WP_VERSION}.zip -d /tmp && \
    rm wordpress-${WP_VERSION}.zip

RUN sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php84/php-fpm.d/www.conf && \
    sed -i 's|user = .*|user = nginx|' /etc/php84/php-fpm.d/www.conf && \
    sed -i 's|group = .*|group = nginx|' /etc/php84/php-fpm.d/www.conf

COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 9000

CMD ["./entrypoint.sh"]
