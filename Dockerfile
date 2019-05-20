FROM alpine:3.7

LABEL maintainer="Pierre GINDRAUD <pgindraud@gmail.com>"

ARG PHPPGADMIN_VERSION=5.6.0
ARG PREFIX_PATH="/phppgadmin"

ENV POSTGRES_NAME=PostgreSQL \
    POSTGRES_HOST=localhost \
    POSTGRES_PORT=5432 \
    POSTGRES_DEFAULTDB=template1 \
    PHPPGADMIN_LOGIN_SECURITY=1 \
    PHPPGADMIN_OWNED_ONLY=0 \
    PHPPGADMIN_SHOW_COMMENTS=1 \
    PHPPGADMIN_SHOW_ADVANCED=0 \
    PHPPGADMIN_SHOW_SYSTEM=0 \
    PHPPGADMIN_SHOW_OIDS=0 \
    PHPPGADMIN_USE_XHTML_STRICT=0 \
    PHPPGADMIN_THEME=default \
    PHPPGADMIN_PLUGINS=""

# Install dependencies
RUN apk --no-cache add \
      curl \
      nginx \
      php5 \
      php5-fpm \
      php5-curl \
      php5-gd \
      php5-mcrypt \
      php5-pgsql \
      postgresql \
      supervisor \
      tar \
    && mkdir -p /run/nginx /var/www${PREFIX_PATH} /data/data \
    && cd /var/www${PREFIX_PATH} \
    && export PHPPGADMIN_DASH_VERSION=$(echo "${PHPPGADMIN_VERSION}" | sed 's/\./-/g') \
    && curl -O -L "https://github.com/phppgadmin/phppgadmin/releases/download/REL_${PHPPGADMIN_DASH_VERSION}/phpPgAdmin-${PHPPGADMIN_VERSION}.tar.bz2" \
    && tar -xf "phpPgAdmin-${PHPPGADMIN_VERSION}.tar.bz2" --strip 1 \
    && rm "phpPgAdmin-${PHPPGADMIN_VERSION}.tar.bz2" \
    && rm -rf conf/config.inc.php-dist LICENSE CREDITS DEVELOPERS FAQ HISTORY INSTALL TODO TRANSLATORS \
    && apk --no-cache del curl tar

# Add some configurations files
COPY root/ /
COPY config.inc.php /var/www${PREFIX_PATH}/conf/

# Apply PHP FPM configuration
RUN sed -i -e "s|;clear_env\s*=\s*no|clear_env = no|g" /etc/php5/php-fpm.conf \
    && sed -i -e "s|;daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf \
    && echo "php_admin_value[display_errors] = 'stderr'" >> /etc/php5/php-fpm.conf \
    && sed -i -e "s|listen\s*=\s*127\.0\.0\.1:9000|listen = /var/run/php-fpm5.sock|g" /etc/php5/php-fpm.conf \
    && sed -i -e "s|;listen\.owner\s*=\s*|listen.owner = |g" /etc/php5/php-fpm.conf \
    && sed -i -e "s|;listen\.group\s*=.*$|listen.group = nginx|g" /etc/php5/php-fpm.conf \
    && sed -i -e "s|;listen\.mode\s*=\s*|listen.mode = |g" /etc/php5/php-fpm.conf \
    && chown -R nobody /var/www

EXPOSE 80
WORKDIR /var/www

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
