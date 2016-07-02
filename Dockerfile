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

# Sets the nickname if you didn't set one, default ports, and the path
#  where to mount the key material used by the clients. 
ENV TOR_NICKNAME=Tor4 \
    TERM=xterm \
    TOR_ORPORT=7000 \
    TOR_DIRPORT=9030 \
    TOR_DIR=/tor 

# Add the official torproject.org Debian Tor repository
# - this will always build/install the latest stable version
COPY ./config/tor-apt-sources.list /etc/apt/sources.list.d/

# Build & Install:
# - add the gpg key used to sign the packages
# - install build dependencies (and nano)
# - add a 'builder' user for compiling the package as a non-root user
# - build Tor in ~/debian-packages and install the new Tor package
# - backup torrc & cleanup all dependencies and caches
# - adds only 13 MB to the Debian base image (without obfsproxy, which adds another 60 MB)
# TODO: Allow selection of which version of tor to build
RUN gpg --keyserver keys.gnupg.net --recv 886DDD89 && \
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - && \
    apt-get update && \
    build_deps="build-essential fakeroot devscripts quilt libssl-dev zlib1g-dev libevent-dev \
        asciidoc docbook-xml docbook-xsl xmlto dh-apparmor libseccomp-dev dh-systemd \
        libsystemd-dev pkg-config dh-autoreconf hardening-includes" && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install $build_deps \
        obfsproxy \
        tor-geoipdb \
        init-system-helpers \
        pwgen \
        nano && \ 
    adduser --disabled-password --gecos "" builder && \
    su builder -c 'mkdir -v ~/debian-packages; cd ~/debian-packages && \
    apt-get -y source tor && \
    cd tor-* && \
    debuild -rfakeroot -uc -us' && \
    dpkg -i /home/builder/debian-packages/tor_*.deb && \
    mv -v /etc/tor/torrc /etc/tor/torrc.default && \
    deluser --remove-home builder && \
    apt-get -y purge --auto-remove $build_deps && \
    apt-get clean && rm -r /var/lib/apt/lists/*

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
