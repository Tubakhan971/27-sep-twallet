# Base image
FROM php:8.2-apache

# Set environment variable for Render (optional)
ENV PORT=10000

# Install system dependencies and PHP extensions
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Install Composer globally (without multi-stage COPY)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy app into container
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Update Apache to listen on Render port and log to stdout/stderr
CMD bash -lc '\
  sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf && \
  sed -i "s#<VirtualHost \*:80>#<VirtualHost *:${PORT}>#" /etc/apache2/sites-available/000-default.conf && \
  sed -i "s@ErrorLog .*@ErrorLog /dev/stderr@" /etc/apache2/sites-available/000-default.conf && \
  sed -i "s@CustomLog .*@CustomLog /dev/stdout combined@" /etc/apache2/sites-available/000-default.conf && \
  apache2-foreground'
