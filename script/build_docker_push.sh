#! /bin/bash
set -ex
IMAGE_NAME=crawler-proxy
DOCKER_PATH=${REGISTRY_PATH}/${IMAGE_NAME}:$VERSION
docker build -t ${DOCKER_PATH} .
docker push ${DOCKER_PATH}
