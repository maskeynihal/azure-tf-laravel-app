#!/bin/bash
sudo apt update -y \
&& sudo apt install -y curl git acl \
&& sudo apt install nginx -y \
&& sudo apt install software-properties-common -y\
&& sudo add-apt-repository ppa:ondrej/php -y \
&& sudo add-apt-repository ppa:ondrej/nginx -y \
&& sudo apt update -y \
&&  sudo apt install php8.1-fpm -y \
&& sudo apt install \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-bcmath \
    php8.1-zip \
    php8.1-curl \
    php8.1-mcrypt \
    php8.1-mysql -y \
&& sudo apt install mysql-server -y \
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& sudo mv composer.phar /usr/local/bin/composer \
&& curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
&& export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
&& nvm install 16 \
&& nvm use 16 \
&& npm install yarn --location=global
