#
# Nasqueron  - Base PHP CLI image
#

FROM debian:jessie
MAINTAINER Sébastien Santoro aka Dereckson <dereckson+nasqueron-docker@espace-win.org>

#
# Prepare the container
#

ENV PHP_VERSION 7.4.3
ENV ONIGURAMA_VERSION 6.9.4
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_BUILD_DEPS bzip2 \
		file \
		libbz2-dev \
		libzip-dev \
		libcurl4-openssl-dev \
		libedit-dev \
		libjpeg-dev \
		libpng12-dev \
		libreadline6-dev \
		libsqlite3-dev \
		libssl-dev \
		libxslt1-dev \
		libxml2-dev \
		libreadline-dev \
		xz-utils	
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y ca-certificates curl libxml2 autoconf \
    gcc libc-dev make pkg-config nano less tmux wget git locales unzip \
    $PHP_BUILD_DEPS $PHP_EXTRA_BUILD_DEPS \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && dpkg-reconfigure locales

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
	5A52880781F755608BF815FC910DEB46F53EA312 \
	42670A7FE4D0441C8E4632349E4FDC074A4EF02D \
	&& mkdir -p $PHP_INI_DIR/conf.d \
	&& set -x \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc \
	&& gpg --verify php.tar.bz2.asc \
	&& mkdir -p /usr/src/php \
	&& tar -xof php.tar.bz2 -C /usr/src/php --strip-components=1 \
	&& rm php.tar.bz2* \
	&& wget -O /usr/src/onigurama.tar.gz https://github.com/kkos/oniguruma/releases/download/v$ONIGURAMA_VERSION/onig-$ONIGURAMA_VERSION.tar.gz \
	&& cd /usr/src \
	&& tar xzf onigurama.tar.gz \
	&& cd onig-$ONIGURAMA_VERSION \
	&& ./configure && make && make install \
	&& cd /usr/src/php \
	&& export CFLAGS="-fstack-protector-strong -fpic -fpie -O2" \
	&& export CPPFLAGS="$CFLAGS" \
	&& export LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
	&& ./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--disable-cgi \
		--enable-mysqlnd \
		--enable-bcmath \
		--with-bz2 \
		--enable-calendar \
		--with-curl \
		--enable-gd \
		--with-jpeg \
		--enable-ftp  \
		--with-libedit \
		--enable-mbstring \
		--with-mysqli \
		--with-pdo-mysql \
		--enable-pcntl \
		--with-openssl \
		--with-xsl \
		--with-readline \
		--with-zlib \
		--with-zip \
		--with-pear \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
	&& make clean \
	&& pecl install APCu \
	&& cd /opt \
	&& wget https://psysh.org/psysh && chmod 755 psysh \
	&& ln -s /opt/psysh /usr/local/bin \
	&& curl -sS https://getcomposer.org/installer | php \
	&& ln -s /opt/composer.phar /usr/local/bin/composer

RUN groupadd -r app -g 433 && \
	mkdir /home/app && \
	useradd -u 431 -r -g app -d /home/app -s /bin/sh -c "Default application account" app && \
	chown -R app:app /home/app && \
	chmod 711 /home/app

COPY files / 
