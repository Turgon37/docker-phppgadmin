FROM alpine:3.4
MAINTAINER Pierre GINDRAUD <pgindraud@gmail.com>

ENV PHPPGADMIN_VERSION=5.1 \
    POSTGRES_NAME=PostgreSQL \
    POSTGRES_HOST=localhost \
    POSTGRES_PORT=5432 \
    POSTGRES_DEFAULTDB=template1

# Install dependencies
RUN apk --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ add \
    supervisor \
    curl \
    nginx \
    php5 \
    php5-fpm \
    php5-curl \
    php5-gd \
    php5-mcrypt \
    php5-pgsql \
    postgresql \
    tar && \

# Install phppadmin sources
    mkdir -p /run/nginx && \
    mkdir -p /var/www /data/data && \
    cd /var/www && \
    curl -O -L "http://downloads.sourceforge.net/project/phppgadmin/phpPgAdmin%20%5Bstable%5D/phpPgAdmin-${PHPPGADMIN_VERSION}/phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz" && \
    tar -xzf "phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz" --strip 1 && \
    rm "phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz" && \
    rm -rf conf/config.inc.php-dist LICENSE CREDITS DEVELOPERS FAQ HISTORY INSTALL TODO TRANSLATORS && \
# Fix bug with current postgres version
    sed -i 's|$cmd = $exe . " -i";|$cmd = $exe;|' /var/www/dbexport.php && \
# Remove dependencies
    apk --no-cache del curl tar


# Add some configurations files
COPY config.inc.php /var/www/conf/
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

# Apply PHP FPM configuration
RUN sed -i -e "s|;clear_env\s*=\s*no|clear_env = no|g" /etc/php5/php-fpm.conf && \
    sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
    echo "php_admin_value[display_errors] = 'stderr'" >> /etc/php5/php-fpm.conf && \
    sed -i -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm5.sock|g" /etc/php5/php-fpm.conf && \
    sed -i -e "s|;listen\.owner\s*=\s*|listen.owner = |g" /etc/php5/php-fpm.conf && \
    sed -i -e "s|;listen\.group\s*=.*$|listen.group = nginx|g" /etc/php5/php-fpm.conf && \
    sed -i -e "s|;listen\.mode\s*=\s*|listen.mode = |g" /etc/php5/php-fpm.conf && \
    chown -R nobody /var/www

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
