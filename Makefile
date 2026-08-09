.PHONY: help install update key migrate fresh seed rollback \
        run test cache-clear optimize-clear \
        route-list config-clear config-cache \
        view-clear storage-link

help:
	@echo "Available commands:"
	@echo ""
	@echo "  make install          Install Composer dependencies"
	@echo "  make update           Update Composer dependencies"
	@echo "  make key              Generate Laravel application key"
	@echo ""
	@echo "  make run              Start Laravel development server"
	@echo ""
	@echo "  make migrate          Run database migrations"
	@echo "  make fresh            Fresh migration"
	@echo "  make seed             Run database seeders"
	@echo "  make rollback         Rollback the latest migration"
	@echo ""
	@echo "  make test             Run Laravel tests"
	@echo ""
	@echo "  make cache-clear      Clear application cache"
	@echo "  make optimize-clear   Clear all optimized files"
	@echo "  make config-clear     Clear configuration cache"
	@echo "  make config-cache     Cache configuration"
	@echo "  make view-clear       Clear compiled Blade views"
	@echo "  make route-list       Display application routes"
	@echo "  make storage-link     Create storage symbolic link"

install:
	composer install

update:
	composer update

key:
	php artisan key:generate

run:
	php artisan serve

migrate:
	php artisan migrate

fresh:
	php artisan migrate:fresh

seed:
	php artisan db:seed

rollback:
	php artisan migrate:rollback

test:
	php artisan test

cache-clear:
	php artisan cache:clear

optimize-clear:
	php artisan optimize:clear

config-clear:
	php artisan config:clear

config-cache:
	php artisan config:cache

view-clear:
	php artisan view:clear

route-list:
	php artisan route:list

storage-link:
	php artisan storage:link