FROM php:7.4-apache

ENV DEBIAN_FRONTEND=noninteractive \
	COMPOSER_ALLOW_SUPERUSER=1 \
	PHP_USER_ID=33 \
	PHP_ENABLE_XDEBUG=0 \
	PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
	TERM=linux \
	VERSION_PANDOC=2.11.4

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
		imagemagick libcurl3-dev libicu-dev libfreetype6-dev libjpeg-dev libjpeg62-turbo-dev libonig-dev libmagickwand-dev libpq-dev libpng-dev \
		# async
		libevent-dev libuv1-dev \
		# ssh2
		libssh2-1-dev \
		# other good stuff from yii2-docker
		libxml2-dev libzip-dev zlib1g-dev default-mysql-client openssh-client nano unzip libcurl4-openssl-dev libssl-dev \
	&& chsh -s /usr/bin/zsh \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN set -ex \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		wkhtmltopdf \
	&& curl -Ls "https://github.com/jgm/pandoc/releases/download/${VERSION_PANDOC}/pandoc-${VERSION_PANDOC}-1-amd64.deb" -o /tmp/pandoc.deb \
	&& apt-get install /tmp/pandoc.deb \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN set -ex \
	&& git clone --recursive https://github.com/adsr/phpspy.git \
	&& cd phpspy \
	&& make \
	&& cp phpspy /usr/bin/ \
	&& cd .. \
	&& rm -rf phpspy

RUN set -ex \
	&& docker-php-source extract \
	&& docker-php-ext-configure gd \
		--enable-gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	&& docker-php-ext-install \
		gd \
	&& docker-php-ext-configure imap \
		--with-kerberos \
		--with-imap-ssl \
	&& docker-php-ext-install \
		imap \
	&& docker-php-ext-install \
		pcntl posix sockets ffi \
		soap zip curl bcmath exif \
		iconv intl mbstring opcache \
		pdo_mysql pdo_pgsql \
	&& rm -rf /tmp/* \
	&& docker-php-source delete

RUN set -ex \
	&& docker-php-source extract \
	&& pecl install \
		redis imagick igbinary ast zstd xdebug swoole \
	&& docker-php-ext-enable \
		redis imagick igbinary ast zstd \
	&& pecl install \
		uv-0.2.4 ssh2-beta \
	&& docker-php-ext-enable \
		uv ssh2 \
	&& rm -rf /tmp/* \
	&& docker-php-source delete

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
	&& curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s "https://blackfire.io/api/v1/releases/probe/php/linux/amd64/{$version}" \
	&& mkdir -p /tmp/blackfire \
	&& tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
	&& mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
	&& printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
	&& rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz \
	# binary CLI
	&& mkdir -p /tmp/blackfire \
    && architecture=$(uname -m) \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/cli/linux/$architecture | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -rf /tmp/blackfire

COPY copy/base copy/apache /

RUN set -ex \
	# Apache modules
	&& a2enmod rewrite headers ssl \
	# antidote
	&& git clone --depth=1 https://github.com/mattmc3/antidote.git /root/.antidote \
	&& zsh /root/setup.zsh \
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
