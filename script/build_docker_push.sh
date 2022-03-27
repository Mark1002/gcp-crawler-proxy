#! /bin/bash
read -r -e -p "Please enter project_id: " projectName

# Set project environment
gcloud config set project "${projectName}"
DOCKER_PATH=asia.gcr.io/${projectName}/crawler-proxy:latest
docker build -t "${DOCKER_PATH}" ./squid
docker push "${DOCKER_PATH}"
