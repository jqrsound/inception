FROM alpine:3.23.5

RUN apk add --no-cache nodejs npm git python3 make g++ sqlite

WORKDIR /app

RUN git clone https://github.com/louislam/uptime-kuma.git . \
    && git checkout 1.23.13

RUN npm ci --production \
    && npm run download-dist

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "server/server.js"]
