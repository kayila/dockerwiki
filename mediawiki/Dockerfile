FROM alpine:3.6

RUN apk add --no-cache \
    php7 \
    php7-apcu \
    php7-curl \
    php7-xml \
    php7-fpm \
    php7-ctype \
    php7-fileinfo \
    php7-gd \
    php7-json \
    php7-mysqli \
    php7-pdo_mysql \
    php7-dom \
    php7-openssl \
    php7-iconv \
    php7-opcache \
    php7-intl \
    php7-mcrypt \
    php7-common \
    php7-xmlreader \
    php7-phar \
    php7-mbstring \
    php7-session \
    diffutils \
    git \
    nginx \
    imagemagick \
    python3 \
  && apk add --no-cache --virtual=.build-dependencies wget ca-certificates \
  # Set python3 as default python
  && ln -s python3 /usr/bin/python \
  # Install Composer
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && php -r "unlink('composer-setup.php');" \
  # Tweak configs
  && sed -i \
    -e "s,;daemonize = yes,daemonize = no,g" \
    -e "s,;cgi.fix_pathinfo=1,cgi.fix_pathinfo=0,g" \
    -e "s,post_max_size = 8M,post_max_soze = 100M,g" \
    -e "s,upload_max_filesize = 2M,upload_max_filesize = 100M,g" \
    /etc/php7/php.ini \
  && sed -i \
    -e "s,;daemonize = yes,daemonize = no,g" \
    -e "s,user = nobody,user=www,g" \
    -e "s,;chdir = /var/www,chdir = /var/www/mediawiki,g" \
    -e "s,;listen.owner = nobody,listen.owner = www,g" \
    -e "s,;listen.group = nobody,listen.owner = www,g" \
    -e "s,listen = 127.0.0.1:9000,listen = 0.0.0.0:9000,g" \
    -e "s,;clear_env = no,clear_env = no,g" \
    /etc/php7/php-fpm.d/www.conf \
  # Forward php error logs to docker log collector
  && ln -sf /dev/stderr /var/log/php7/error.log \
  # Download & extract MediaWiki
  && mkdir -p /var/www \
  && wget https://releases.wikimedia.org/mediawiki/1.30/mediawiki-core-1.30.0.tar.gz -O /tmp/mediawiki.tar.gz \
  && tar -C /var/www -xzvf /tmp/mediawiki.tar.gz \
  && mv /var/www/mediawiki* /var/www/mediawiki \
  && rm -rf /tmp/mediawiki.tar.gz \
  # Add the www user and make everything belong to them
  && adduser -S -D -H www \
  && chown -R www /var/www/mediawiki \
  # Delete packages only require for the build phase
  && apk del .build-dependencies \
  # Forward nginx logs to docker log collector
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf
# TODO Make this not required, damn it's hacky
RUN mkdir -p /var/tmp/nginx /run/nginx \
  && chown -R www /run/nginx /var/tmp/nginx \
  && chmod -R 777 /var/tmp/nginx

WORKDIR /var/www/mediawiki

EXPOSE 80

CMD /start.sh
