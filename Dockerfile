FROM ubuntu:22.04 as documentserver
LABEL maintainer Ascensio System SIA <support@onlyoffice.com>

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive PG_VERSION=14

ARG ONLYOFFICE_VALUE=onlyoffice

RUN apt-get -y update && \
    apt-get -yq install wget apt-transport-https gnupg locales

COPY config /app/ds/setup/config/
COPY run-document-server.sh /app/ds/run-document-server.sh

EXPOSE 80 443

ARG TARGETARCH
ARG PRODUCT_EDITION=
ARG COMPANY_NAME=onlyoffice
ARG PRODUCT_NAME=documentserver
ARG PACKAGE_URL="http://download.onlyoffice.com/install/documentserver/linux/${COMPANY_NAME}-${PRODUCT_NAME}${PRODUCT_EDITION}_$TARGETARCH.deb"

ENV COMPANY_NAME=$COMPANY_NAME \
    PRODUCT_NAME=$PRODUCT_NAME \
    PRODUCT_EDITION=$PRODUCT_EDITION

RUN wget -q -P /tmp "$PACKAGE_URL" && \
    apt-get -y update && \
    service postgresql start && \
    apt-get -yq install /tmp/$(basename "$PACKAGE_URL") && \
    service postgresql stop && \
    service supervisor stop && \
    chmod 755 /app/ds/*.sh && \
    rm -f /tmp/$(basename "$PACKAGE_URL") && \
    rm -rf /var/log/$COMPANY_NAME && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/log/$COMPANY_NAME /var/lib/$COMPANY_NAME /var/www/$COMPANY_NAME/Data /var/lib/postgresql /var/lib/rabbitmq /var/lib/redis /usr/share/fonts/truetype/custom

ENTRYPOINT ["/app/ds/run-document-server.sh"]
