# Dockerfile written by Florian Humer <florian.humer@gmail.com>
#

FROM php:7.3-apache-buster

MAINTAINER Florian Humer <florian.humer@gmail.com>

ENV SSP_VERSION 1.17.2
ENV SSP_HASH 0e2fd641e8cba2966437fb64591e28a73fb90bae3bc97949c60a47a5b8c1e80e
ENV GOMPLATE_VERSION 3.3.1


RUN apt update && apt install -y wget libldap2-dev nano gettext-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install ldap 

RUN wget https://github.com/hairyhenderson/gomplate/releases/download/v$GOMPLATE_VERSION/gomplate_linux-amd64-slim -O /usr/local/bin/gomplate \
    && chmod +x /usr/local/bin/gomplate

RUN set -x \
    && wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SSP_VERSION/simplesamlphp-$SSP_VERSION.tar.gz -O /tmp/simplesamlphp-$SSP_VERSION.tar.gz \
    && echo "$SSP_HASH  /tmp/simplesamlphp-$SSP_VERSION.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/simplesamlphp-$SSP_VERSION.tar.gz -C /tmp \
    && mv /tmp/simplesamlphp-$SSP_VERSION /var/simplesaml \
    && chown -R www-data:www-data /var/simplesaml \
    && rm /tmp/simplesamlphp-$SSP_VERSION.tar.gz \
    && mkdir app \
    && mkdir -p /var/www/html/simplesaml/modules/habidat

COPY themes /var/simplesaml/modules/themes
COPY public /var/simplesaml/public
COPY templates /app/templates
COPY params.yml.dist /params.default.yml
COPY sso.conf /sso.conf

WORKDIR /var/simplesaml

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
