#!/bin/bash

#set -e
#set -o pipefail

# add user to docker group
#sudo usermod -aG docker $USER
#newgrp docker

# build image
TS=`date +%s`
DOCKER_BUILDKIT=1 docker build -t base_ngraph-he . 2>&1 | tee docker-build-${TS}.log
