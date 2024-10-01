FROM python:2.7

LABEL maintainer="poojan@kpinfo.tech"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Set environment variables
ENV LANG=C.UTF-8

# Install system dependencies
RUN set -x; \
        apt-get update \
        && apt-get install figlet \
        && figlet "KP Infotech" \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            python-gevent \
            python-pip \
            python-renderpm \
            python-watchdog \
            gnupg2 \
            xfonts-75dpi \
            xfonts-base \
            lsb-release


RUN wget https://snapshot.debian.org/archive/debian/20160413T160058Z/pool/main/libp/libpng/libpng12-0_1.2.54-6_amd64.deb \
    && dpkg -i libpng12-0_1.2.54-6_amd64.deb

RUN wget https://snapshot.debian.org/archive/debian/20100115T221920Z/pool/main/libj/libjpeg8/libjpeg8_8-1_amd64.deb \
    && dpkg -i libjpeg8_8-1_amd64.deb

RUN wget http://snapshot.debian.org/archive/debian/20190501T215844Z/pool/main/g/glibc/multiarch-support_2.28-10_amd64.deb \
    && dpkg -i multiarch-support*.deb

RUN wget http://snapshot.debian.org/archive/debian/20170705T160707Z/pool/main/o/openssl/libssl1.0.0_1.0.2l-1%7Ebpo8%2B1_amd64.deb \
    && dpkg -i libssl1.0.0*.deb

# Copy Wkhtmltopdf
COPY wkhtmltox-0.12.2.1_linux-trusty-amd64.deb/ ./
RUN dpkg -i --force-depends  wkhtmltox-0.12.2.1_linux-trusty-amd64.deb


# Install PostgreSQL client-9.6
#RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
#    curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
#    && apt-get update \
#    && apt-get install -y postgresql-client-9.6


# create odoo directory
RUN mkdir /opt/odoo

# Copy requirements.txt (here seperately to avoid dependency installs on every build even if requirements.txt hasn't changed)
# https://stackoverflow.com/questions/34398632/docker-how-to-run-pip-requirements-txt-only-if-there-was-a-change
COPY odoo8/requirements.txt /opt/odoo/requirements.txt

# Set the working directory
WORKDIR /opt/odoo/

# Install pip packages
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Copy the odoo source code
COPY odoo8/ ./

ENTRYPOINT ["python", "openerp-server"]