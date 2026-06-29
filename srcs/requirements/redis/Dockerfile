FROM alpine:3.23

# Install redis server
RUN apk add --no-cache redis

# Copy custom configuration file
COPY ./conf/redis.conf /etc/redis.conf

# Expose the default Redis port internally
EXPOSE 6379

# Run redis server pointing to our custom configuration file
# --protected-mode no allows connections from our wordpress container
CMD ["redis-server", "/etc/redis.conf", "--protected-mode", "no"]