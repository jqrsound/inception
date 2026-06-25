FROM alpine:3.23

RUN apk add --no-cache nginx openssl

# Remove default configurations to avoid port conflicts or overrides
RUN rm -rf /etc/nginx/http.d/default.conf

# Copy your clean master configuration file directly 
COPY ./nginx.conf /etc/nginx/nginx.conf

COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 443

CMD ["./entrypoint.sh"]
