FROM php:8.0-apache
ENV PROVISION_CONTEXT "development"
ENV WEB_DOCUMENT_ROOT=/var/www/html/public

ARG PSR_VERSION=1.1.0
ARG PHALCON_VERSION=5.0.0alpha6

# Install Git
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

# Install Zip/Unzip
RUN apt-get install -y libzip-dev zip \
    && docker-php-ext-install zip

# Install mysql extension
RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql

# Install memcached and redis
RUN apt-get install -y libmemcached-dev

RUN pecl channel-update pecl.php.net
RUN pecl install memcached redis

RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini
RUN echo extension=redis.so >> /usr/local/etc/php/conf.d/redis.ini

RUN pecl install psr-${PSR_VERSION}
RUN pecl install phalcon-${PHALCON_VERSION}

RUN echo extension=psr.so >> /usr/local/etc/php/conf.d/phalcon_psr.ini
RUN echo extension=phalcon.so >> /usr/local/etc/php/conf.d/phalcon.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Setup document root
RUN sed -ri -e 's!/var/www/html!${WEB_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${WEB_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# enable a2enmod rewrite
RUN a2enmod rewrite

COPY bin/*.sh /opt/docker/provision/entrypoint.d/
