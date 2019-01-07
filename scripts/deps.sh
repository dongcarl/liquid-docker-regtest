#! /usr/bin/env bash

# Causes the shell to exit if any subcommand or pipeline returns a non-zero status
set -e

apt-get update && apt-get install -yqq \
        curl \
        make \
        build-essential \
        libtool \
        autotools-dev \
        automake \
        pkg-config \
        libssl-dev \
        libevent-dev \
        bsdmainutils \
        libboost-system-dev \
        libboost-filesystem-dev \
        libboost-chrono-dev \
        libboost-program-options-dev \
        libboost-test-dev \
        libboost-thread-dev \
        libminiupnpc-dev \
        libzmq3-dev \
        tor \
        jq \
        libdb-dev \
        libdb++-dev
