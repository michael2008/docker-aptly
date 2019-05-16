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

FROM debian:stretch

MAINTAINER bryan@turbojets.net

ENV DEBIAN_FRONTEND noninteractive
ENV DIST=debian
ENV RELEASE=stretch

# Install curl needed to install pgp keys
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf  \
 && apt-get -q update                                \
 && apt-get -y install curl                          \
                       gnupg1                        \
                       gpgv1                         \
                       apt-transport-https           \
 && rm -rf /var/lib/apt/lists/*

# Add Aptly repository
RUN echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list \
 && echo "nameserver 10.0.0.71" >> /etc/resolv.conf \
 && for server in ha.pool.sks-keyservers.net \
              hkp://p80.pool.sks-keyservers.net:80 \
              keyserver.ubuntu.com \
              hkp://keyserver.ubuntu.com:80 \
              pgp.mit.edu; \
    do \
        apt-key adv --keyserver "$server" --recv-keys ED75B5A4483DA07C && break || echo "Trying new server..."; \
    done

# Add Nginx repository
RUN echo "deb http://nginx.org/packages/$DIST/ $RELEASE nginx" > /etc/apt/sources.list.d/nginx.list \
 && echo "deb-src http://nginx.org/packages/$DIST/ $RELEASE nginx" >> /etc/apt/sources.list.d/nginx.list \
 && echo "nameserver 10.0.0.71" >> /etc/resolv.conf \
 && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

# Add EPICS repository
RUN echo "deb https://epicsdeb.bnl.gov/$DIST/ $RELEASE/staging main contrib" > /etc/apt/sources.list.d/epics.list \
 && echo "deb-src https://epicsdeb.bnl.gov/$DIST/ $RELEASE/staging main contrib" >> /etc/apt/sources.list.d/epics.list \
 && echo "nameserver 10.0.0.71" >> /etc/resolv.conf \
 && curl -fsSL https://epicsdeb.bnl.gov/debian/repo-key.pub | apt-key add -

# Update APT repository and install packages
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf  \
 && apt-get -q update                                \
 && apt-get -y install aptly                         \
                       bash-completion               \
                       bzip2                         \
                       graphviz                      \
                       supervisor                    \
                       nginx                         \
                       nsls2-archive-keyring         \
                       wget                          \
                       xz-utils                      \
 && rm -rf /var/lib/apt/lists/*

# Install Aptly Configuration
COPY assets/aptly.conf /etc/aptly.conf

# Enable Aptly Bash completions
RUN echo "nameserver 10.0.0.71" >> /etc/resolv.conf  \
  wget https://github.com/smira/aptly/raw/master/bash_completion.d/aptly \
    -O /etc/bash_completion.d/aptly \
  && echo "if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi" >> /etc/bash.bashrc

# Install Nginx Config
COPY assets/nginx.conf.sh /opt/nginx.conf.sh
COPY assets/supervisord.nginx.conf /etc/supervisor/conf.d/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install scripts
COPY assets/*.sh /opt/
COPY assets/update_mirror/update_mirror_epics.sh /opt/update_mirror.sh

# Bind mount location
VOLUME [ "/opt/aptly" ]

# Execute Startup script when container starts
ENTRYPOINT [ "/opt/startup.sh" ]
