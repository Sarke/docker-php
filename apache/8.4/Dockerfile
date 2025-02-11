FROM php:8.4-apache

ENV DEBIAN_FRONTEND=noninteractive \
	COMPOSER_ALLOW_SUPERUSER=1 \
	PHP_USER_ID=33 \
	PHP_ENABLE_XDEBUG=0 \
	PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
	TERM=xterm-256color

RUN set -ex \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		git curl apt-utils \
		rsync tar xz-utils dnsutils ssl-cert binutils \
		net-tools iproute2 \
		pv zsh zstd \
		graphviz \
		# pdf
		ghostscript qpdf poppler-utils \
		# other good stuff from yii2-docker
		default-mysql-client openssh-client nano unzip \
		# python3
		# python3 python3-pip python3-venv \
	&& chsh -s /usr/bin/zsh \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN set -ex \
	&& IPE_GD_WITHOUTAVIF=1 \
	&& IPE_SWOOLE_WITHOUT_IOURING=1 \
	&& install-php-extensions \
		ast \
		bcmath \
		exif \
		ffi \
		gd \
		geos \
		igbinary \
		imagick \
		imap \
		inotify \
		intl \
		opcache \
		pcntl \
		pdo_dblib \
		pdo_mysql \
		pdo_pgsql \
		redis \
		soap \
		sockets \
		ssh2 \
		uv \
		xsl \
		zip \
		zstd \
	&& IPE_DONT_ENABLE=1 \
	&& install-php-extensions \
		blackfire \
		swoole \
		xdebug \
	&& echo "Done installing PHP extensions"

COPY copy/base copy/apache /

RUN set -ex \
	# Apache modules
	&& a2enmod rewrite headers ssl \
	# antidote
	&& git clone --depth=1 https://github.com/mattmc3/antidote.git /root/.antidote \
	&& antidote bundle < /root/.zsh_plugins.txt > /root/.zsh_plugins.sh \
	# Add GITHUB_API_TOKEN support for composer
	&& chmod 700 \
		/usr/local/bin/docker-php-entrypoint \
		/usr/local/bin/composer \
	# Install composer
	&& curl -sS https://getcomposer.org/installer | php -- \
		--filename=composer.phar \
		--install-dir=/usr/local/bin \
	&& composer clear-cache

WORKDIR /app
