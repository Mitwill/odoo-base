# Use an official Python runtime as a parent image
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
            lsb-release \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
        && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install PostgreSQL client-9.6
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y postgresql-client-9.6


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
