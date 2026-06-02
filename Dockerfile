FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    pkg-config \
    unzip \
    git \
    cron \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        intl \
        mbstring \
        xml \
        opcache \
        curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite
RUN echo '<Directory /var/www/html>\n    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>' >> /etc/apache2/apache2.conf

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/assets \
    && chmod -R 775 /var/www/html/application/logs

RUN echo "*/2 * * * * www-data php /var/www/html/index.php email/process >> /var/log/cron_email.log 2>&1" >> /etc/cron.d/mapos \
    && echo "*/5 * * * * www-data php /var/www/html/index.php email/retry >> /var/log/cron_email.log 2>&1" >> /etc/cron.d/mapos \
    && chmod 0644 /etc/cron.d/mapos

RUN echo "upload_max_filesize = 64M\npost_max_size = 64M\nmax_execution_time = 120\nmemory_limit = 256M\nopcache.enable=1\nopcache.memory_consumption=128\nopcache.max_accelerated_files=8000" > /usr/local/etc/php/conf.d/mapos.ini

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN sed -i 's/\r//' /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

EXPOSE 80
CMD ["/docker-entrypoint.sh"]
