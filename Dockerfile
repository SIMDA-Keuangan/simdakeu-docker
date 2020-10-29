FROM ubuntu:20.04

LABEL author="Simda Keuangan - BPKP"

ARG DEBIAN_FRONTEND=noninteractive

# UPDATE PACKAGES
RUN apt-get update

# INSTALL SYSTEM UTILITIES
RUN apt-get install -y \
    apt-utils \
    curl \
    git \
    apt-transport-https \
    software-properties-common \
    g++ \
    build-essential \
    dialog

# INSTALL APACHE2
RUN apt-get install -y apache2
RUN a2enmod rewrite

# INSTALL locales
RUN apt-get install -qy language-pack-en-base \
    && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# INSTALL PHP & LIBRARIES
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
    php-pear \
    php7.3 \
    php7.3-common \
    php7.3-dev \
    php7.3-mbstring \
    php7.3-xml \
    php7.3-cli \
    php7.3-curl \
    php7.3-gd \
    php7.3-imagick \
    php7.3-xdebug \
    php7.3-zip \
    php7.3-odbc \
    libapache2-mod-php7.3

RUN pecl install xdebug
RUN echo "zend_extension=xdebug.so" > /etc/php/7.3/cli/conf.d/20-xdebug.ini
RUN echo "zend_extension=xdebug.so" > /etc/php/7.3/apache2/conf.d/20-xdebug.ini
# COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
# COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY image-files/ /

# Add GITHUB_API_TOKEN support for composer
RUN chmod 700 \
        /usr/local/bin/docker-php-entrypoint \
        /usr/local/bin/composer

# INSTALL ODBC DRIVER & TOOLS
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    mssql-tools \
    unixodbc \
    unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN exec bash

# INSTALL & LOAD SQLSRV DRIVER & PDO
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.3/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.3/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 7.3 sqlsrv pdo_sqlsrv

# INSTALL COMPOSER
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin/ --filename=composer
RUN chmod +x /usr/local/bin/composer

# INSTALL EDITORS
RUN apt-get update && apt-get install nano vim -y

RUN rm -rf /var/www/html && ln -s /app/web/ /var/www/html || true

WORKDIR /app

# COPY . /app

RUN chown -R www-data:www-data /var/lib/php/sessions

RUN mkdir -p /app/web/_protected/runtime /app/web/assets && \
    chmod -R 777 /app/web/_protected/runtime /app/web/assets && \
    chown -R www-data:www-data /app/web/_protected/runtime /app/web/assets

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]