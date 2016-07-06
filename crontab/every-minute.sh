#!/bin/bash

GIT_DIR=$(git rev-parse --show-toplevel)

VOTOLEGAL_API_PORT="8105" # warning... deveria ter isso só em um lugar..

if /bin/fuser $VOTOLEGAL_API_PORT/tcp ; then
    echo "voto legal is running"
else
    cd $GIT_DIR;
    git pull;
    ./deploy.sh
fi
