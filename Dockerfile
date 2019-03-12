FROM ubuntu:16.04

# Use baseimage-docker's init system.
#CMD ["/sbin/my_init"]

# Set correct environment variables
ENV HOME /root

# MYSQL ROOT PASSWORD
ARG MYSQL_ROOT_PASS=root    

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    locales \
    software-properties-common \
    python-software-properties \
    build-essential \
    curl \
    git \
    unzip \
    mcrypt \
    wget \
    openssl \
    autoconf \
    openssh-client \
    g++ \
    make \
    libssl-dev \
    libcurl4-openssl-dev \
    libsasl2-dev \
    libcurl3 \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && apt-get --purge autoremove -y

# Ensure UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN locale-gen en_US.UTF-8

# OpenSSL
RUN mkdir -p /usr/local/openssl/include/openssl/ && \
    ln -s /usr/include/openssl/evp.h /usr/local/openssl/include/openssl/evp.h && \
    mkdir -p /usr/local/openssl/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.a /usr/local/openssl/lib/libssl.a && \
    ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/local/openssl/lib/

RUN mkdir /root/.ssh/

RUN chmod 700 /root/.ssh/

# NODE JS
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install nodejs -qq

# MYSQL
# /usr/bin/mysqld_safe
RUN bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASS"' && \
		bash -c 'debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASS"' && \
		DEBIAN_FRONTEND=noninteractive apt-get update && \
		DEBIAN_FRONTEND=noninteractive apt-get install -qqy mysql-server-5.7

RUN echo "[mysqld] \n sql_mode=IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" > /etc/mysql/mysql.conf.d/disable_strict_mode.cnf

# PHP Extensions
ENV PHP_VERSION 7.1
RUN add-apt-repository -y ppa:ondrej/php && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y -qq php-pear \
      php${PHP_VERSION}-dev \
      php${PHP_VERSION}-cli \
      php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-apcu \
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-bz2 \
      php${PHP_VERSION}-calendar \
      php${PHP_VERSION}-common \
      php${PHP_VERSION}-ctype \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dba \
      php${PHP_VERSION}-dom \
      php${PHP_VERSION}-embed \
      php${PHP_VERSION}-enchant \
      php${PHP_VERSION}-exif \
      php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-ftp \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-gettext \
      php${PHP_VERSION}-gmp \
      php${PHP_VERSION}-iconv \
      php${PHP_VERSION}-imagick \
      php${PHP_VERSION}-imap \
      php${PHP_VERSION}-intl \
      php${PHP_VERSION}-json \
      php${PHP_VERSION}-ldap \
#      php${PHP_VERSION}-libsodium \
      php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-mcrypt \
      php${PHP_VERSION}-memcached \
      php${PHP_VERSION}-mongodb \
      php${PHP_VERSION}-mysqli \
      php${PHP_VERSION}-mysqlnd \
      php${PHP_VERSION}-odbc \
      php${PHP_VERSION}-opcache \
#      php${PHP_VERSION}-openssl \
      php${PHP_VERSION}-pdo \
      php${PHP_VERSION}-pgsql \
      php${PHP_VERSION}-phar \
      php${PHP_VERSION}-phpdbg \
      php${PHP_VERSION}-posix \
      php${PHP_VERSION}-pspell \
      php${PHP_VERSION}-redis \
      php${PHP_VERSION}-shmop \
      php${PHP_VERSION}-snmp \
      php${PHP_VERSION}-soap \
      php${PHP_VERSION}-sockets \
      php${PHP_VERSION}-sqlite3 \
      php${PHP_VERSION}-sysvmsg \
      php${PHP_VERSION}-sysvsem \
      php${PHP_VERSION}-sysvshm \
      php${PHP_VERSION}-tidy \
      php${PHP_VERSION}-tokenizer \
      php${PHP_VERSION}-wddx \
      php${PHP_VERSION}-xdebug \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-xmlreader \
      php${PHP_VERSION}-xmlrpc \
      php${PHP_VERSION}-xmlwriter \
      php${PHP_VERSION}-xsl \
      php${PHP_VERSION}-zip

# Time Zone
RUN echo "date.timezone = UTC" > "/etc/php/${PHP_VERSION}/cli/conf.d/date_timezone.ini" && \
    echo "date.timezone = UTC" > "/etc/php/${PHP_VERSION}/fpm/conf.d/date_timezone.ini"

#VOLUME /root/.composer

# Environmental Variables
ENV COMPOSER_HOME /root/.composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel Envoy
RUN composer global require 'laravel/envoy=^1.4' 'symplify/easy-coding-standard:5.4.14'

# Goto temporary directory.
WORKDIR /tmp

RUN apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm i npm -g

LABEL maintainer="imposibrus <root@imposibrus.space>"
LABEL version="1.3.3"
