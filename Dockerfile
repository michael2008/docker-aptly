# Copyright 2018-2019 Artem B. Smirnov
# Copyright 2018 Jon Azpiazu
# Copyright 2016 Bryan J. Hong
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:xenial

LABEL maintainer="urpylka@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED75B5A4483DA07C \
    && echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list

# Update APT repository & install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -q update --allow-unauthenticated  \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends --allow-unauthenticated \
    aptly=1.4.0 \
    bzip2 \
    gnupg=1.4.20-1ubuntu3.3 \
    gpgv=1.4.20-1ubuntu3.3 \
    graphviz=2.38.0-12ubuntu2.1 \
    supervisor=3.2.0-2ubuntu0.2 \
    nginx \
    wget \
    xz-utils=5.1.1alpha+20120614-2ubuntu2 \
    apt-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Aptly Configuration
COPY assets/aptly.conf /etc/aptly.conf

# Install scripts
COPY assets/*.sh /opt/

# Install Nginx Config
RUN rm /etc/nginx/sites-enabled/*
COPY assets/supervisord.nginx.conf /etc/supervisor/conf.d/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Bind mount location
VOLUME [ "/opt/aptly" ]

# Execute Startup script when container starts
ENTRYPOINT [ "/opt/startup.sh" ]
