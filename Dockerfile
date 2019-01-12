#
# Dockerfile for the Private Tor Network 
#
# This is a dockerfile to build a Debian host and
# compile a version of tor from the Tor apt repos.
# NOTE: This is a modification of chriswayg's solid
# base.  
#
# Usage:
#   This works best using a docker compose command so you can run the
#   necessary other servers for it to talk to. But if you want o run
#   manually:
#   
#   docker run --rm -it -e ROLE=DA antitree/tor-server /bin/bash

FROM debian:jessie
MAINTAINER Antitree antitree@protonmail.com

# Sets which version of tor to use. See the Tor Projects git page for available tags
# Examples:
#  * tor-0.2.8.4-rc
#  * tor-0.2.7.6
#  * tor-0.2.7.5
#  * release-0.2.1
ENV TOR_VER="maint-0.3.4"
#ENV TOR_VER="master"
# NOTE sometimes the master branch doesn't compile so I'm sticking with the release
#  feel free to change this to master to get the latest and greatest

# Sets the nickname if you didn't set one, default ports, and the path
#  where to mount the key material used by the clients. 
ENV TERM=xterm \
    TOR_ORPORT=7000 \
    TOR_DIRPORT=9030 \
    TOR_DIR=/tor 

# Install build dependencies
RUN apt-get update && \
    build_temps="build-essential automake" && \ 
    build_deps="libssl-dev zlib1g-dev libevent-dev ca-certificates\
        dh-apparmor libseccomp-dev dh-systemd \
        git" && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install $build_deps $build_temps \
        init-system-helpers \
        pwgen && \
    mkdir /src && \
    cd /src && \
    git clone https://git.torproject.org/tor.git && \
    cd tor && \
    git checkout ${TOR_VER} && \
    ./autogen.sh && \
    ./configure --disable-asciidoc && \
    make && \
    make install && \
    apt-get -y purge --auto-remove $build_temps && \
    apt-get clean && rm -r /var/lib/apt/lists/* && \
    rm -rf /src/*

# Copy the base tor configuration file
COPY ./config/torrc* /etc/tor/

# Copy docker-entrypoint and the fingerprint script
COPY ./scripts/ /usr/local/bin/

# Persist data (Usually don't want this)
#VOLUME /etc/tor /var/lib/tor

# Create the shared directory
RUN mkdir ${TOR_DIR}

# ORPort, DirPort, ObfsproxyPort
# TODO make these match the env variables
# TODO is this necessary anymore?
EXPOSE 9001 9030 9051

ENTRYPOINT ["docker-entrypoint"]

CMD ["tor", "-f", "/etc/tor/torrc"]
