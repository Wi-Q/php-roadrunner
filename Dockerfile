ARG RR_VERSION
ARG RR_IMAGE=spiralscout/roadrunner:${RR_VERSION}
ARG PHP_VERSION
ARG PHP_IMAGE=php:${PHP_VERSION}

FROM ${RR_IMAGE} as rr

FROM ${PHP_IMAGE}

RUN apk update && apk add --no-cache \
  libzip-dev \
  unzip \
  git

# Install PHP Extensions
RUN docker-php-ext-install zip \
  && docker-php-ext-install sockets \
  && docker-php-ext-install opcache \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-enable opcache \
  && docker-php-ext-install bcmath \
  && docker-php-ext-enable bcmath

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i "s/;date.timezone =.*/date.timezone = UTC/" /usr/local/etc/php/php.ini \
    && sed -i "s/memory_limit = 128M/memory_limit = 256M/" /usr/local/etc/php/php.ini

WORKDIR /var/www/html

# Copy Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN composer global config github-oauth.github.com f1c802f819b4eaa7a49a69f97275fbc8a9f14245

# Copy RoadRunner
COPY --from=rr /usr/bin/rr /usr/bin/rr

COPY ./.rr.yaml /etc/rr/.rr.yaml
COPY ./.rr.dev.yaml /etc/rr/.rr.dev.yaml
