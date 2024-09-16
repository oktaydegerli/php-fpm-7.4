FROM php:7.4-fpm

RUN set -eux && \
    sed -i 's/^deb /# deb /g' /etc/apt/sources.list && \
    echo 'deb http://archive.debian.org/debian/ stretch main contrib non-free' >> /etc/apt/sources.list && \
    apt-get update -y && apt-get upgrade -y

RUN pecl channel-update pecl.php.net

# Apt paketlerini yükle

RUN apt-get install -y --no-install-recommends wget
RUN apt-get install -y --no-install-recommends git
RUN apt-get install -y --no-install-recommends curl
RUN apt-get install -y --no-install-recommends cron
RUN apt-get install -y --no-install-recommends libcurl4-openssl-dev
RUN apt-get install -y --no-install-recommends libmemcached-dev
RUN apt-get install -y --no-install-recommends libz-dev
RUN apt-get install -y --no-install-recommends libpq-dev
RUN apt-get install -y --no-install-recommends libjpeg-dev
RUN apt-get install -y --no-install-recommends libpng-dev
RUN apt-get install -y --no-install-recommends libfreetype6-dev
RUN apt-get install -y --no-install-recommends libssl-dev
RUN apt-get install -y --no-install-recommends libwebp-dev
RUN apt-get install -y --no-install-recommends libonig-dev
RUN apt-get install -y --no-install-recommends libmcrypt-dev
RUN apt-get install -y --no-install-recommends libxml2-dev
RUN apt-get install -y --no-install-recommends libxslt-dev
RUN apt-get install -y --no-install-recommends jpegoptim
RUN apt-get install -y --no-install-recommends ffmpeg

# Yanlış let's encrypt sertifikasını düzelt. Çünkü eski ve süresi dolmuş bir kök sertifika içeriyor (DST Root CA X3)

RUN sed -i -E 's/(.*DST_Root_CA_X3.*)/!\1/' /etc/ca-certificates.conf

ADD https://letsencrypt.org/certs/isrgrootx1.pem /usr/local/share/ca-certificates/isrgrootx1.pem

RUN update-ca-certificates


# Extensionları yükle

RUN docker-php-ext-install mysqli curl iconv mbstring json mcrypt gettext

RUN docker-php-ext-install simplexml xml xmlrpc

RUN docker-php-ext-install soap xsl


# Redis kurulumu

RUN printf "\n" | pecl install redis-5.3.7

RUN docker-php-ext-enable redis


# Imagemagick kurulumu

RUN apt-get install -y libmagickwand-dev && pecl install imagick && docker-php-ext-enable imagick


# GD kurulumu

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install -j$(nproc) gd


# Composer kurulumu

ENV COMPOSER_BINARY=/usr/local/bin/composer \
    COMPOSER_HOME=/usr/local/composer

ENV PATH $PATH:$COMPOSER_HOME

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar $COMPOSER_BINARY && \
    chmod +x $COMPOSER_BINARY

# Geçici dosyaları temizle ve yeniden güncelle
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && apt-get update -y
