#!/bin/bash

bash /opt/docker/scripts/start-mysql.sh

bash /opt/docker/scripts/start-mysql.sh
echo "MySQL:"

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Connection established?"
    sleep 5
    mysql -udocker -pdocker -e "status" #> /dev/null 2>&1
    RET=$?
done

start=$(date +%s)

mysql -udocker -pdocker -e "CREATE DATABASE IF NOT EXISTS shopware DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';"

echo "Shopware:"
git clone https://github.com/shopware/shopware.git /var/www/shopware

chmod -Rf 0777 /var/www/shopware/var
chmod -Rf 0777 /var/www/shopware/web
chmod -Rf 0777 /var/www/shopware/files
chmod -Rf 0777 /var/www/shopware/media
chmod -Rf 0777 /var/www/shopware/engine/Shopware/Plugins/Community

cp /opt/shopware/build.properties /var/www/shopware/build/

cd /var/www/shopware/build
ant build-unit

cd /var/www/shopware
wget -O test_images.zip http://releases.s3.shopware.com/test_images.zip
unzip test_images.zip

echo "Add var-dumper"
php composer.phar require symfony/var-dumper --no-interaction --optimize-autoloader

echo "Generate Theme"
php bin/console sw:theme:cache:generate

echo "media migrate - fix for: images are not showing on the page"
php bin/console sw:media:migrate

chmod 0777 /var/www/shopware/config.php
chmod -Rf 0777 /var/www/shopware/var/cache
chmod -Rf 0777 /var/www/shopware/web

echo "Set permissions"
chown -Rf www-data:www-data /var/www


end=$(date +%s)
runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")

echo "---------"
echo "Runtime: ${runtime}"
echo "---------"
