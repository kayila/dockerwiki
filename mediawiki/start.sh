#!/bin/sh
chown -R www /var/www/mediawiki/images
php-fpm7 -F &
nginx
