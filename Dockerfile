FROM php:8.2-fpm

# WSLのUIDとGIDを環境変数として渡す
ARG PUID=1000
ARG PGID=1000

# 必要ライブラリインストール
RUN apt-get update && apt-get install -y \
  unzip \
  git \
  curl \
  libpq-dev \
  tzdata \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libmariadb-dev \
  && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && echo "Asia/Tokyo" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata

# PDO MySQL拡張をインストール
RUN docker-php-ext-install pdo_mysql

# ユーザーとグループを作成し、UIDとGIDを設定する
RUN addgroup --gid ${PGID} laravel && \
  adduser --uid ${PUID} --gid ${PGID} --disabled-password --gecos "" laravel

# Composer のインストール
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Xdebug のインストール
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Xdebug 設定
COPY docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/

# 作業ディレクトリの設定
WORKDIR /var/www/html

# Laravel アプリのコードをコピー & ライブラリインストール
COPY ./laravel/ /var/www/html/
RUN chown -R laravel:laravel /var/www/html/
RUN composer install

# nginx で参照する場所を定義
VOLUME ["/var/www/html/public"]

# 権限の設定（storage, bootstrap/cache）
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

USER laravel

# PHP-FPM を起動
CMD ["php-fpm"]
