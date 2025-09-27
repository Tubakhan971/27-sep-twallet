# Official PHP + Apache image
FROM php:8.3-apache

# Optional: required PHP extensions (example)
RUN docker-php-ext-install pdo pdo_mysql

# Apache modules (pretty URLs etc.)
RUN a2enmod rewrite headers

# App code
COPY . /var/www/html

# Render recommends binding to $PORT (default 10000)
ENV PORT=10000

# Runtime par Apache ko $PORT par shift karo
CMD bash -lc '\
  sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf && \
  sed -i "s#<VirtualHost \\*:80>#<VirtualHost *:${PORT}>#" /etc/apache2/sites-available/000-default.conf && \
  apache2-foreground'
