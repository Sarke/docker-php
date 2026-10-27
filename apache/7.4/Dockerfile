FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive \
	COMPOSER_ALLOW_SUPERUSER=1 \
	PHP_USER_ID=33 \
	PHP_ENABLE_XDEBUG=0 \
	PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
	TERM=linux \
	VERSION_PANDOC=2.19.2

RUN set -ex \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		git curl apt-utils ca-certificates lsb-release \
	&& curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
	&& dpkg -i /tmp/debsuryorg-archive-keyring.deb \
	&& echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		apache2 libapache2-mod-php7.4 \
		php7.4-cli php7.4-common php7.4-dev \
		php7.4-ast php7.4-bcmath php7.4-curl php7.4-gd \
		php7.4-igbinary php7.4-imagick php7.4-imap php7.4-intl \
		php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache \
		php7.4-pgsql php7.4-redis php7.4-soap php7.4-ssh2 \
		php7.4-xml php7.4-xdebug php7.4-zip php7.4-zstd \
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
		# image utilities
		webp imagemagick \
		# async
		libevent-dev libuv1-dev \
		# other good stuff from yii2-docker
		default-mysql-client openssh-client nano unzip zlib1g-dev libssl-dev \
	&& chsh -s /usr/bin/zsh \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN set -ex \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install \
		wkhtmltopdf \
	&& curl -Ls "https://github.com/jgm/pandoc/releases/download/${VERSION_PANDOC}/pandoc-${VERSION_PANDOC}-1-amd64.deb" -o /tmp/pandoc.deb \
	&& apt-get install /tmp/pandoc.deb \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
	&& curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s "https://blackfire.io/api/v1/releases/probe/php/linux/amd64/{$version}" \
	&& mkdir -p /tmp/blackfire \
	&& tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
	&& mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
	&& printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php/7.4/mods-available/blackfire.ini \
	&& phpenmod -v 7.4 blackfire \
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
