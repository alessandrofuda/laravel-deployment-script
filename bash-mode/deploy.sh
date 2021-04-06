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
./vendor/bin/phpunit || error_exit $((++step - 1))


echo $((++step))') - Maintenance mode'
php artisan down --message="Deploying in progress. Wait a moment please.." || error_exit $((++step - 1))


echo $((++step))') - Pull from repository'
git pull origin main || error_exit $((++step - 1))


echo $((++step))') - Composer install (without dev dependencies)'
composer install --optimize-autoloader --no-dev || error_exit $((++step - 1))


echo $((++step))') - Regenerate config cache'
php artisan config:clear || error_exit $((++step - 1))
php artisan config:cache || error_exit $((++step - 1))


echo $((++step))') - Regenerate routes cache'
php artisan route:clear || error_exit $((++step - 1))
php artisan route:cache || error_exit $((++step - 1))


echo $((++step))') - Regenerate views caches'
php artisan cache:clear || error_exit $((++step - 1))
php artisan view:clear || error_exit $((++step - 1))
php artisan view:cache || error_exit $((++step - 1))


echo $((++step))') - Clear expired password reset tokens'
php artisan auth:clear-resets || error_exit $((++step - 1))


echo $((++step))') - update storage SimLinks (make an absolute path)'
php artisan storage:link || error_exit $((++step - 1))


echo $((++step))') - Npm install & run (production mode)'
npm install --production || error_exit $((++step - 1))
npm run prod || error_exit $((++step - 1))


echo $((++step))') - Artisan migrate'
php artisan migrate --force || error_exit $((++step - 1))


# Force Run Eventual(!) db seeder (ex roles/permission tables or predefined data stored in db)
# php artisan db::seed (--class=ExampleTableSeeder) || error_exit $((++step - 1)) PAY ATTENTION! -- ONLY FOR FIRST deploy !!!!!!!


echo $((++step))') - Turn off Maintenance Mode'
php artisan up || error_exit $((++step - 1))

echo $line

echo 'Deploy Complete!!'
