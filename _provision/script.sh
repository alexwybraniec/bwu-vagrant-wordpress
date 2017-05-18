#!/usr/bin/env bash

# prepare for an unattended installation
export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get upgrade -y

apt-get install -y build-essential htop screen git-core python-software-properties software-properties-common

apt-get install -y nginx
rm /etc/nginx/sites-enabled/default

add-apt-repository ppa:ondrej/php
apt-get update

apt-get install -y php7.0-fpm php7.0-mysql php-memcache php7.0-curl php7.0-mbstring php7.0-xml

apt-get install -y --allow-unauthenticated mariadb-server mariadb-client

if [ -f $VAGRANT_SYNCED_DIR/vagrant/.mysql-passes ]
  then
    rm -f $VAGRANT_SYNCED_DIR/vagrant/.mysql-passes
fi

echo "vagrant:vagrant" >> ${VAGRANT_SYNCED_DIR}/vagrant/.mysql-passes

mysql -uroot -e "CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'vagrant'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON * . * TO 'vagrant'@'localhost';"
mysql -uroot -e "FLUSH PRIVILEGES;"
mysql -uroot -e "CREATE DATABASE vagrant DEFAULT CHARACTER SET utf8_mb4 DEFAULT COLLATE utf8_general_ci;"

echo "Created vagrant database"

cp -r ${VAGRANT_SYNCED_DIR}/vagrant/_provision/nginx_conf/global /etc/nginx/
cp ${VAGRANT_SYNCED_DIR}/vagrant/_provision/nginx_conf/nginx_wp /etc/nginx/sites-available

ln -s /etc/nginx/sites-available/nginx_wp /etc/nginx/sites-enabled/nginx_wp

sed -i 's/^upload_max_filesize =.*/upload_max_filesize = 16M/' /etc/php/7.0/fpm/php.ini
sed -i 's/^post_max_size =.*/post_max_size = 16M/' /etc/php/7.0/fpm/php.ini

service php7.0-fpm restart
service nginx restart

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
sudo -u vagrant -i -- wp --info
sudo -u vagrant -i -- wp core download --path=/vagrant/_project/_public
