FROM alpine:3.23

RUN apk add --no-cache nginx openssl

RUN rm -rf /etc/nginx/http.d/default.conf

COPY ./nginx.conf /etc/nginx/nginx.conf

COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 443

CMD ["./entrypoint.sh"]
