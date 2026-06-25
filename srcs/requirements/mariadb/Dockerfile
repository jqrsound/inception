FROM alpine:3.23

RUN apk add --no-cache \
	mariadb \
	mariadb-client

COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 3306

CMD ["./entrypoint.sh"]