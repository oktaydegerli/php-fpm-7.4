FROM php:7.4-fpm-bullseye

RUN pecl channel-update pecl.php.net

# Apt paketlerini yükle

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    curl \
    cron \
    libcurl4-gnutls-dev \
    libmemcached-dev \
    libz-dev \
    libbz2-dev \
    libpq-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libwebp-dev \
    libonig-dev \
    libmcrypt-dev \
    libxml2-dev \
    libxslt-dev


# Yanlış let's encrypt sertifikasını düzelt. Çünkü eski ve süresi dolmuş bir kök sertifika içeriyor (DST Root CA X3)

RUN sed -i -E 's/(.*DST_Root_CA_X3.*)/!\1/' /etc/ca-certificates.conf

ADD https://letsencrypt.org/certs/isrgrootx1.pem /usr/local/share/ca-certificates/isrgrootx1.pem

RUN update-ca-certificates


# Extensionları yükle

docker-php-ext-install mysqli curl iconv mbstring json gettext simplexml xml xmlrpc soap xsl

# Redis kurulumu

RUN printf "\n" | pecl install redis-5.3.7

RUN docker-php-ext-enable redis


# Imagemagick kurulumu

RUN apt-get install -y libmagickwand-dev
RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick

# GD kurulumu

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
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
