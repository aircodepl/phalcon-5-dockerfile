FROM php:8.0.0-apache
ENV PROVISION_CONTEXT "development"
ENV WEB_DOCUMENT_ROOT=/var/www/html/public

ARG PSR_VERSION=1.1.0
ARG PHALCON_VERSION=5.0.0alpha3
ARG PHALCON_EXT_PATH=phalcon/safe

# Install PSR + Phalcon based on https://github.com/MilesChou/docker-phalcon/blob/master/7.4/apache/Dockerfile
RUN set -xe && \
        # Download PSR, see https://github.com/jbboehr/php-psr
        curl -LO https://github.com/jbboehr/php-psr/archive/v${PSR_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PSR_VERSION}.tar.gz && \
        # Download Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH} \
        && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PSR_VERSION}.tar.gz \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION} \
        && \
        php -m \

COPY docker-phalcon-* /usr/local/bin/
# Installing PSR + Phalcon ends here.

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

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Setup document root
RUN sed -ri -e 's!/var/www/html!${WEB_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${WEB_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# enable a2enmod rewrite
RUN a2enmod rewrite

# Rename config files
RUN mv '/usr/local/etc/php/conf.d/docker-php-ext-psr.ini' '/usr/local/etc/php/conf.d/docker-php-ext-phalcon-psr.ini'

COPY bin/*.sh /opt/docker/provision/entrypoint.d/
