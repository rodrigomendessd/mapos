FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libicu-dev \
    libonig-dev libxml2-dev libcurl4-openssl-dev pkg-config \
    unzip git cron \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli zip intl mbstring xml opcache curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite \
    && echo '<Directory /var/www/html>\n    AllowOverride All\n</Directory>' >> /etc/apache2/apache2.conf

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/assets /var/www/html/application/logs

RUN echo "upload_max_filesize=64M\npost_max_size=64M\nmax_execution_time=120\nmemory_limit=256M" > /usr/local/etc/php/conf.d/mapos.ini

EXPOSE 80
CMD ["apache2-foreground"]
