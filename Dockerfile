FROM php:7.3.11-apache

RUN set -xe \
    && apt-get update \
    && apt-get install -y libpng-dev libjpeg-dev libpq-dev libxml2-dev libldap-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd mysqli pgsql soap ldap \
    && rm -rf /var/lib/apt/lists/*

ENV MANTIS_VER 2.24.1
# ENV MANTIS_SHA512 55a8cae5036c34fc346fb5585eeffdd86d252ac1f64bbf44e361d09aedad8a24ac4f047f2659ccc80343784aa92a1a4217fe2c41873b6c0ace208af7ebc37c55
ENV MANTIS_MD5 a5a001ffa5a9c9a55848de1fbf7fae95
ENV MANTIS_SHA1 f4ecf2ef8316e530bcfe501a0068110f28361b8d
ENV MANTIS_URL https://downloads.sourceforge.net/project/mantisbt/mantis-stable/${MANTIS_VER}/mantisbt-${MANTIS_VER}.tar.gz
# https://sourceforge.net/projects/mantisbt/files/mantis-stable/2.24.1/mantisbt-2.24.1.tar.gz/download
ENV MANTIS_FILE mantisbt.tar.gz
ENV MANTIS_TIMEZONE Europe/Berlin
ENV PHP_MAX_UPLOAD_SIZE "2M"

RUN set -xe \
    && curl -fSL ${MANTIS_URL} -o ${MANTIS_FILE} \
    # && sha512sum ${MANTIS_FILE} \
    && md5sum ${MANTIS_FILE} \
    # && echo "${MANTIS_SHA512}  ${MANTIS_FILE}" | sha512sum -c \
    && tar -xz --strip-components=1 -f ${MANTIS_FILE} \
    && rm ${MANTIS_FILE} \
    && chown -R www-data:www-data .

COPY mantisbt-entrypoint.sh /usr/local/bin/mantisbt-entrypoint.sh

WORKDIR /var/www/html

ENTRYPOINT /usr/local/bin/mantisbt-entrypoint.sh