FROM alpine:3.23

RUN apk add --no-cache nodejs npm git python3 make g++ sqlite

WORKDIR /app

RUN git clone https://github.com/louislam/uptime-kuma.git . \
    && git checkout 1.23.13

RUN npm ci --production \
    && npm run download-dist

COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 3001

CMD ["./entrypoint.sh"]
