#! /usr/bin/env bash

# Causes the shell to exit if any subcommand or pipeline returns a non-zero status
set -e

# $1=BRANCH_COMMIT $2=REPO_NAME $3=REPO_HOST $4=DAEMON_NAME

# if [ "$4" = "" -o "$4" = "disabled_daemon" ]; then
#     exit 0
# fi

BRANCH_DIR=$2-$1
BRANCH_URL=$3/$2/archive/$1.tar.gz
NUM_JOBS=$(nproc)

curl -L $BRANCH_URL | tar xz
cd $BRANCH_DIR
./autogen.sh
./configure --without-gui --with-incompatible-bdb
make -j$NUM_JOBS "src/"$4"d" "src/"$4"-cli"
