FROM php:8.4-apache

ENV DEBIAN_FRONTEND=noninteractive \
	COMPOSER_ALLOW_SUPERUSER=1 \
	PHP_USER_ID=33 \
	PHP_ENABLE_XDEBUG=0 \
	PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
	TERM=linux

RUN set -ex \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		git curl apt-utils \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN set -ex \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		rsync tar xz-utils dnsutils ssl-cert binutils \
		net-tools iproute2 \
		pv zsh \
		graphviz \
		# pdf
		ghostscript qpdf poppler-utils \
		# imap
		libc-client-dev libkrb5-dev \
		# webp and gd
		webp libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev zlib1g-dev \
		# magic
		imagemagick libcurl3-dev libicu-dev libfreetype6-dev libjpeg-dev libjpeg62-turbo-dev libonig-dev \
		libmagickwand-dev libmagickcore-dev libpq-dev libpng-dev \
		# async
		libevent-dev libuv1-dev \
		# ssh2
		libssh2-1-dev \
		# other good stuff from yii2-docker
		libxml2-dev libxslt-dev libzip-dev zlib1g-dev default-mysql-client openssh-client nano unzip libcurl4-openssl-dev libssl-dev \
		# python3
		# python3 python3-pip python3-venv \
	&& chsh -s /usr/bin/zsh \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN set -ex \
	&& docker-php-source extract \
	&& docker-php-ext-configure gd \
		--enable-gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	&& docker-php-ext-install \
		gd \
	&& docker-php-ext-install \
		pcntl posix sockets ffi \
		soap zip curl bcmath exif \
		iconv intl mbstring opcache \
		pdo_mysql pdo_pgsql \
		xml xsl \
	&& rm -rf /tmp/* \
	&& docker-php-source delete

RUN set -ex \
	&& docker-php-source extract \
	&& pecl install \
#		event redis imagick igbinary ast xdebug swoole \
		imap redis igbinary ast xdebug \
	&& docker-php-ext-enable \
#		event redis imagick igbinary ast \
		imap redis igbinary ast \
	&& rm -rf /tmp/* \
	&& docker-php-source delete

# RUN set -ex \
# 	&& docker-php-source extract \
# 	&& pecl install \
# 		imagick \
# 	&& docker-php-ext-enable \
# 		imagick \
# 	&& rm -rf /tmp/* \
# 	&& docker-php-source delete

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions imagick

# Ensure runtime and assets directories exist
RUN mkdir -p /app/runtime /app/web/assets \
	&& chown -R www-data:www-data /app/runtime /app/web/assets \
	&& chmod -R 775 /app/runtime /app/web/assets

RUN a2enmod rewrite headers ssl

COPY copy/base /
COPY copy/apache /

# Add GITHUB_API_TOKEN support for composer
RUN chmod 700 \
	/usr/local/bin/docker-php-entrypoint \
	/usr/local/bin/composer \
	# Install composer
	&& curl -sS https://getcomposer.org/installer | php -- \
		--filename=composer.phar \
		--install-dir=/usr/local/bin \
	&& composer clear-cache

WORKDIR /app
