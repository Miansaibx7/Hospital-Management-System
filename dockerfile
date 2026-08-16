# ==========================================
# Build Frontend Assets (Node/Vite)
# ==========================================
FROM node:20-alpine AS frontend_builder
WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm ci || npm install

# Copy all files and compile frontend assets (Vite/Mix)
COPY . .
RUN npm run build


# ==========================================
# Build Backend Dependencies
# ==========================================
FROM composer:2.7 AS backend_builder
WORKDIR /app

# Copy composer files and install dependencies
COPY composer.json composer.lock* ./
RUN composer install --no-scripts --no-autoloader --prefer-dist --no-dev

# Copy the rest of the application and generate optimized autoload files
COPY . .
RUN composer dump-autoload --optimize


# ==========================================
# Final Production Image (Apache+PHP)
# ==========================================
FROM php:8.2-apache

# Set DocumentRoot to Laravel's public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Update Apache configuration
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Enable Apache mod_rewrite for Laravel routing
RUN a2enmod rewrite

# Install required system packages
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    zip \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install crucial PHP extensions for a Hospital System:
# - bcmath: Required for precise Payroll and Billing calculations
# - gd: Required for image uploads (patient/doctor profiles, prescriptions)
# - intl: Required for internationalization and localized currency formatting
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Set working directory
WORKDIR /var/www/html

# Copy optimized backend and frontend from previous stages
COPY --from=backend_builder /app /var/www/html
COPY --from=frontend_builder /app/public /var/www/html/public

# Set proper directory permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
2. The docker-compose.yml (Required for Database)
Because your system relies on MySQL for the doctors, patients, appointments, and payroll modules, you need a way to spin up the database and the app together. Create a docker-compose.yml file in your root folder:

YAML
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: hms_app
    restart: unless-stopped
    ports:
      - "8000:8"
    environment:
      - DB_CONNECTION=mysql
      - DB_HOST=db
      - DB_PORT=3306
      - DB_DATABASE=hms_database
      - DB_USERNAME=hms_user
      - DB_PASSWORD=secret
    depends_on:
      - db
    networks:
      - hms_network

  db:
    image: mysql:8.0
    container_name: hms_db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: hms_database
      MYSQL_USER: hms_user
      MYSQL_PASSWORD: secret
      MYSQL_ROOT_PASSWORD: root_secret
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - hms_network

volumes:
  db_data:

networks:
  hms_network:
    driver: bridge