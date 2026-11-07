FROM php:8.3-apache

# Install required system dependencies & PHP extension libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
    libicu-dev libxml2-dev gnutls-bin ghostscript unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli gd zip intl soap opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Apache DocumentRoot to Moodle public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Required Moodle PHP settings
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/moodle.ini

# Create Moodle data directory
RUN mkdir -p /var/www/moodledata \
    && chown -R www-data:www-data /var/www/moodledata

# Copy source files into Apache document root
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80