# Use official PHP + Apache image (pick version you need)
FROM php:8.2-apache

# Install system deps and PHP extensions you need
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev \
  && docker-php-ext-install pdo pdo_mysql zip gd \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Install Composer (optional, but convenient)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy app into container
COPY . /var/www/html

# Set permissions (adjust if you use frameworks)
RUN chown -R www-data:www-data /var/www/html \
  && chmod -R 755 /var/www/html

# Default PORT for Render (helps Render's port detection)
ENV PORT=10000

# At container start: update Apache to listen on $PORT and log to stdout/stderr, then start Apache
CMD bash -lc '\
  # update Listen port and virtualhost dynamically (so runtime $PORT is used) \
  sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf && \
  sed -i "s#<VirtualHost \\*:80>#<VirtualHost *:${PORT}>#" /etc/apache2/sites-available/000-default.conf && \
  # send logs to stdout/stderr so Render shows them in service logs \
  sed -i "s@ErrorLog .*@ErrorLog /dev/stderr@" /etc/apache2/sites-available/000-default.conf && \
  sed -i "s@CustomLog .*@CustomLog /dev/stdout combined@" /etc/apache2/sites-available/000-default.conf && \
  apache2-foreground'
