#!/bin/bash
## to call it: ./deploy.sh


line='------------------------------------------'
echo $line
echo "This is the DEPLOY script, pay attention..."
echo "Do you confirm to proceed? [y,n]"
echo $line

read response

while true; do
    if [ $response = "n" ]; then
        echo "Ok, goodbye!"
        exit
    elif [ $response = "y" ]; then
        echo -e "Ok proceed...\n"
        break
    else
        echo "Enter 'y' for yes or 'n' for no"
        read response
    fi
done


step=0
error_exit() {
    echo -e "\nERROR on step $1), see above! Exit."
    exit 1
}


# echo 'Switch to app folder'
# cd ~/apps/my-app-folder


echo $((++step))') - Running phpunit tests!'
./vendor/bin/phpunit || exit 1


echo $((++step))') - Maintenance mode'
php artisan down --message="Deploying in progress. Wait a moment please.."


echo $((++step))') - Pull from repository'
git pull origin main ||  error_exit $((++step - 1))


echo $((++step))') - Composer install'
composer install --optimize-autoloader --no-dev


echo $((++step))') - Regenerate config cache'
php artisan config:clear
php artisan config:cache


echo $((++step))') - Regenerate routes cache'
php artisan route:clear
php artisan route:cache


echo $((++step))') - Regenerate views caches'
php artisan cache:clear
php artisan view:clear
php artisan view:cache


echo $((++step))') - Clear expired password reset tokens'
php artisan auth:clear-resets


echo $((++step))') - update storage SimLinks (make an absolute path)'
php artisan storage:link


echo $((++step))') - Npm install & run (production mode)'
npm install --production
npm run prod


echo $((++step))') - Artisan migrate'
php artisan migrate --force


# Force Run Eventual(!) db seeder (ex roles/permission tables or predefined data stored in db)
# php artisan db::seed (--class=ExampleTableSeeder)  PAY ATTENTION! -- ONLY FOR FIRST deploy !!!!!!!


echo $((++step))') - Turn off Maintenance Mode'
php artisan up

echo $line

echo 'Deploy Complete!!'
