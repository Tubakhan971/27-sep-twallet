# Use official PHP + Apache image
FROM php:8.2-apache

# Install PHP Extensions
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev \
  && docker-php-ext-install pdo pdo_mysql zip gd

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy project files
COPY . /var/www/html

# Set Permissions
RUN chown -R www-data:www-data /var/www/html

# Expose Railway default port
ENV PORT=8080

# Update Apache to listen on $PORT
CMD sed -i "s/80/${PORT}/" /etc/apache2/ports.conf && apache2-foreground
