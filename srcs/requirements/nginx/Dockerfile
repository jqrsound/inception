FROM alpine:3.23.5

RUN apk add --no-cache nginx openssl

RUN rm -rf /etc/nginx/http.d/default.conf

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./static /var/www/static
RUN chmod -R 755 /var/www/static

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
