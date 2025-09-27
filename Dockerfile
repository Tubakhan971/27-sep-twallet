# After copying your code
COPY . /var/www/html

# Run composer install inside container (optional)
RUN apt-get update && apt-get install -y git unzip \
    && cd /var/www/html \
    && composer install \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html
