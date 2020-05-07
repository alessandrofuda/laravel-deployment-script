# Laravel Deployment Steps

```
# Change to the project directory
cd /path/to/your/domain.com

# Turn on maintenance mode 
php artisan down

# Pull the latest changes from the git repository 
git pull              # (origin master)

# Install/update composer dependecies 
composer install --no-interaction --prefer-dist --optimize-autoloader

# Run database migrations 
php artisan migrate --force

# Force Run Eventual(!) db seeder (ex roles/permission tables or predefined data stored in db)
# php artisan db::seed (--class=ExampleTableSeeder)  PAY ATTENTION!

# Clear caches 
php artisan cache:clear
php artisan route:clear
php artisan config:clear
php artisan view:clear

# Clear expired password reset tokens 
php artisan auth:clear-resets

# Make caches 
php artisan route:cache
php artisan config:cache
php artisan view:cache

# Update storage Simlink (make an absolute path)
php artisan storage:link

## Install node modules 
# npm install

# Build assets using Webpack/Laravel Mix 
# npm run production
# BEST PRACTICE:
# - builds: only into localhost (dev environment with npm & node) &
# - public/assets/app.js & public/assets/app.css: versioned and pulled by production server (Already compiled).

# Turn off maintenance mode
php artisan up 

```



