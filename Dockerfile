FROM php:7.3-cli

RUN rm /etc/apt/preferences.d/no-debian-php && apt-get update && apt-get install -y \
  git \
  curl \
  wget \
  unzip \
  openssh-server \
  software-properties-common \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libicu-dev \
  sqlite3 \
  libsqlite3-dev \
  libxml2-dev \
  libzip4 \
  libzip-dev \
  php-soap \
  libgmp-dev \
  && pecl install xdebug-2.7.1 \
  && pecl install mcrypt-1.0.2 \
  && docker-php-ext-enable mcrypt \
  && docker-php-ext-enable xdebug \
  && docker-php-ext-install gmp \
  && docker-php-ext-install -j$(nproc) iconv \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-install -j$(nproc) bcmath \
  && docker-php-ext-install -j$(nproc) exif \
  && docker-php-ext-configure intl \
  && docker-php-ext-install intl

RUN echo "deb http://deb.debian.org/debian unstable main" >> /etc/apt/sources.list \
  && apt-get update && apt-get install -y php7.3-zip php7.3-mysql \
  && docker-php-ext-install zip

RUN mkdir -p /usr/share/man/man1 \
  && apt-get update && apt-get install -y openjdk-8-jdk-headless ca-certificates-java && update-alternatives --config java

ENV JAVA_OPTS -Dfile.encoding=UTF-8 \
              -Dsun.jnu.encoding=UTF-8

COPY php.ini /usr/local/etc/php/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install pdo_sqlite \
  && docker-php-ext-install soap

RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN useradd -m -s /bin/bash jenkins

RUN echo "jenkins:jenkins" | chpasswd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
