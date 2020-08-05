#!/bin/bash

#set -e
#set -o pipefail

# check if the docker command was found (assumes that docker is installed)
if ! command -v docker &> /dev/null
then
  echo "Run manually following commands prior executing this script to add the current user to the docker group:"
  echo "  sudo usermod -aG docker $USER"
  echo "  newgrp docker"
  exit 1
fi

# build image
TS=`date +%s`
DOCKER_BUILDKIT=1 docker build -t base_ngraph-he . 2>&1 | tee docker-build-${TS}.log
