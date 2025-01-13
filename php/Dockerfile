FROM php:8.2-fpm

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
  zip \
  unzip \
  git \
  curl \
  libpq-dev \
  && docker-php-ext-install pdo_mysql

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
