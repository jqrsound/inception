FROM alpine:3.23

# Install system dependencies
RUN apk add --no-cache nodejs npm git python3 make g++ sqlite

WORKDIR /app

# Clone Uptime Kuma core repository
RUN git clone https://github.com/louislam/uptime-kuma.git . \
    && git checkout 1.23.13

# Install production dependencies and download standard UI package
RUN npm ci --production \
    && npm run download-dist

# 📂 CHANGE HERE: Copy from the same folder as the Dockerfile
COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 3001

CMD ["./entrypoint.sh"]
