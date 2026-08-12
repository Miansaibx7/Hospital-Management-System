#!/bin/sh
set -e

echo "=========================================="
echo " Starting Laravel Development Container"
echo "=========================================="

echo "Checking Laravel application..."

php artisan --version

echo "Clearing Laravel caches..."

php artisan optimize:clear

echo "Running database migrations..."

php artisan migrate --force

echo "Creating storage link..."

php artisan storage:link || true

echo "Setting storage permissions..."

chmod -R 775 storage bootstrap/cache 2>/dev/null || true

echo "Starting Laravel development server..."

exec php artisan serve --host=0.0.0.0 --port=8000