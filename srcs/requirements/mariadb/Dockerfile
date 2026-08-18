FROM alpine:3.23.5

RUN apk add --no-cache \
	mariadb \
	mariadb-client

RUN sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i "s|.*bind-address\s*=\s*.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld", "--datadir=/var/lib/mysql", "--bind-address=0.0.0.0", "--user=mysql", "--port=3306"]
