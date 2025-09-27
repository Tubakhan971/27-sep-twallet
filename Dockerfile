# Use official PHP + Apache image
FROM php:8.2-apache

# Install system deps and PHP extensions
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev \
  && docker-php-ext-install pdo pdo_mysql zip gd \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Install Composer (optional)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy entire app into container (ensure PHP files are in repo root)
COPY . /var/www/html

# Set permissions (so Apache can read & write if needed)
RUN chown -R www-data:www-data /var/www/html \
  && chmod -R 755 /var/www/html

# Set Render default PORT (Render uses 10000 by default)
ENV PORT=10000

# At container start: update Apache to listen on $PORT and log to stdout/stderr
CMD bash -c '\
  # Set Apache Listen port dynamically \
  sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf && \
  sed -i "s#<VirtualHost \\*:80>#<VirtualHost *:${PORT}>#" /etc/apache2/sites-available/000-default.conf && \
  # Ensure DocumentRoot points to /var/www/html (repo root) \
  sed -i "s#DocumentRoot /var/www/html#DocumentRoot /var/www/html#" /etc/apache2/sites-available/000-default.conf && \
  # Send logs to stdout/stderr so Render dashboard shows them \
  sed -i "s@ErrorLog .*@ErrorLog /dev/stderr@" /etc/apache2/sites-available/000-default.conf && \
  sed -i "s@CustomLog .*@CustomLog /dev/stdout combined@" /etc/apache2/sites-available/000-default.conf && \
  # Start Apache in foreground \
  apache2-foreground'
