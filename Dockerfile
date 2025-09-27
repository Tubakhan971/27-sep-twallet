FROM php:8.1-apache

# Copy files to Apache server folder
COPY . /var/www/html/

# Give permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
