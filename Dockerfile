FROM ubuntu:16.04

WORKDIR /build_docker

COPY scripts/deps.sh scripts/deps.sh
RUN scripts/deps.sh
# RUN apt-get update
# RUN apt-get install -y software-properties-common

# RUN apt-add-repository -y ppa:bitcoin/bitcoin
# RUN apt-get update

# RUN apt-get install -y bitcoin-qt=0.16.3 bitcoind=0.16.3


# RUN apt-get update && apt-get install -y python-pip jq
# COPY docker/daemon/requirements.txt /build_docker/requirements.txt
# RUN pip install -r requirements.txt --require-hashes

COPY scripts/build-with-wallet.sh scripts/build-with-wallet.sh

ENV CORE_DAEMON_NAME=bitcoin
ENV CORE_BRANCH_COMMIT=49e34e288005a5b144a642e197b628396f5a0765
ENV CORE_REPO_HOST=https://github.com/bitcoin
ENV CORE_REPO_NAME=bitcoin
RUN scripts/build-with-wallet.sh $CORE_BRANCH_COMMIT $CORE_REPO_NAME $CORE_REPO_HOST $CORE_DAEMON_NAME

# Install elementsd
ENV ELEMENTS_DAEMON_NAME=elements
ENV ELEMENTS_BRANCH_COMMIT=43f6cdbd3147d9af450b73c8b8b8936e3e4166df
ENV ELEMENTS_REPO_HOST=https://github.com/ElementsProject
ENV ELEMENTS_REPO_NAME=elements
RUN scripts/build-with-wallet.sh $ELEMENTS_BRANCH_COMMIT $ELEMENTS_REPO_NAME $ELEMENTS_REPO_HOST $ELEMENTS_DAEMON_NAME

ENV BITCOIN_BRANCH_DIR=bitcoin-49e34e288005a5b144a642e197b628396f5a0765
ENV BITCOIN_DAEMON=bitcoind

ENV REGTEST_HOST=0.0.0.0
ENV REGTEST_ALLLOWFROM=0.0.0.0/0

ENV REGTEST_DATADIR=/build_docker/.regtest/
ENV REGTEST_RPCPORT=18535
ENV REGTEST_PORT=18536
ENV REGTEST_ZMQ=tcp://0.0.0.0:18537
ENV REGTEST_RPCUSER=user18535
ENV REGTEST_RPCPASSWORD=password18535

ENV ELEMENTS_BRANCH_DIR=elements-43f6cdbd3147d9af450b73c8b8b8936e3e4166df
ENV ELEMENTS_DAEMON=elementsd

ENV ELEMENTS_ALLLOWFROM=0.0.0.0/0
ENV ELEMENTS_HOST=0.0.0.0

ENV ELEMENTSREGTEST_DATADIR=/build_docker/.elements/
ENV ELEMENTSREGTEST_RPCPORT=7041
ENV ELEMENTSREGTEST_PORT=7042
ENV ELEMENTSREGTEST_ZMQ=tcp://0.0.0.0:7043
ENV ELEMENTSREGTEST_RPCUSER=user7041
ENV ELEMENTSREGTEST_RPCPASSWORD=password7041

ENV ELEMENTSREGTEST2_DATADIR=/build_docker/.elements2/
ENV ELEMENTSREGTEST2_RPCPORT=7043
ENV ELEMENTSREGTEST2_PORT=7044

RUN ln -s /build_docker/$BITCOIN_BRANCH_DIR/src/$BITCOIN_DAEMON /usr/local/bin/$BITCOIN_DAEMON
RUN ln -s /build_docker/$ELEMENTS_BRANCH_DIR/src/$ELEMENTS_DAEMON /usr/local/bin/$ELEMENTS_DAEMON
COPY scripts/liquid1-cli /usr/local/bin/liquid1-cli
COPY scripts/liquid2-cli /usr/local/bin/liquid2-cli
COPY scripts/bitcoin-cli /usr/local/bin/bitcoin-cli

RUN mkdir $REGTEST_DATADIR $ELEMENTSREGTEST_DATADIR $ELEMENTSREGTEST2_DATADIR

ENTRYPOINT $BITCOIN_DAEMON \
  -daemon \
  -rpcbind=$REGTEST_HOST:$REGTEST_RPCPORT \
  -datadir=$REGTEST_DATADIR \
  -rpcallowip=$REGTEST_ALLLOWFROM \
  -rpcuser=$REGTEST_RPCUSER \
  -rpcpassword=$REGTEST_RPCPASSWORD \
  -zmqpubhashblock=$REGTEST_ZMQ \
  -port=$REGTEST_PORT \
  -logips \
  -logtimestamps \
  -server \
  -txindex \
  -listen \
  -discover \
  -dbcache=8000 \
  -maxmempool=8000 \
  -regtest \
  -addresstype=legacy > /dev/null 2>&1 & \
$ELEMENTS_DAEMON \
  -rpcbind=$ELEMENTS_HOST:$ELEMENTSREGTEST_RPCPORT \
  -datadir=$ELEMENTSREGTEST_DATADIR \
  -rpcallowip=$ELEMENTS_ALLLOWFROM \
  -rpcuser=$ELEMENTSREGTEST_RPCUSER \
  -rpcpassword=$ELEMENTSREGTEST_RPCPASSWORD \
  -port=$ELEMENTSREGTEST_PORT \
  -zmqpubhashblock=$ELEMENTSREGTEST_ZMQ \
  -logips \
  -logtimestamps \
  -server \
  -txindex \
  -listen \
  -discover \
  -validatepegin=0 \
  -dbcache=8000 \
  -maxmempool=8000 \
  -fdefaultconsistencychecks=0 \
  -regtest > /dev/null 2>&1 & \
$ELEMENTS_DAEMON \
  -rpcbind=$ELEMENTS_HOST:$ELEMENTSREGTEST2_RPCPORT \
  -datadir=$ELEMENTSREGTEST2_DATADIR \
  -rpcallowip=$ELEMENTS_ALLLOWFROM \
  -rpcuser=$ELEMENTSREGTEST_RPCUSER \
  -rpcpassword=$ELEMENTSREGTEST_RPCPASSWORD \
  -port=$ELEMENTSREGTEST2_PORT \
  -zmqpubhashblock=$ELEMENTSREGTEST_ZMQ \
  -logips \
  -logtimestamps \
  -server \
  -txindex \
  -listen \
  -discover \
  -validatepegin=0 \
  -dbcache=8000 \
  -maxmempool=8000 \
  -fdefaultconsistencychecks=0 \
  -regtest \
  -addnode=0.0.0.0:$ELEMENTSREGTEST_PORT  > /dev/null 2>&1 & \
sleep 10 && bash

