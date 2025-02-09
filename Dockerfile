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

# 作業ディレクトリの設定
WORKDIR /var/www/html

# Laravelアプリのコードをコピー(Laravelのアプリケーションをコンテナに含める)
COPY . /var/www/html

# Composerのパッケージをインストール(コンテナ内で依存パッケージをインストール)
RUN composer install --no-dev --optimize-autoloader

# 権限の設定(storageやbootstrap/cacheに書き込み権限付与)
RUN chown -R www-data:www-data /var/www/html \
  && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# .envファイルの作成
RUN cp .env.example .env

# Laravelのキャッシュクリア & 最適化
RUN php artisan config:clear \
  && php artisan cache:clear \
  && php artisan route:cache \
  && php artisan view:cache

# PHP-FPMを起動
CMD ["php-fpm"]
