#! /bin/bash

set -ex

read -r -e -p "Please enter project_id: " projectName
gcloud config set compute/region asia-east1
# Set project environment
gcloud config set project "${projectName}"
# get compute default service account
computeDefaultServiceAccount="$(gcloud iam service-accounts list --filter='Compute Engine default service account' |grep -oE '[0-9]+-compute@developer\.gserviceaccount\.com')"
DOCKER_PATH=asia.gcr.io/${projectName}/crawler-proxy:latest
# create vm template
gcloud beta compute --project="${projectName}" instance-templates \
    create-with-container crawler-proxy-template --machine-type=e2-micro \
    --network=projects/"${projectName}"/global/networks/default \
    --network-tier=PREMIUM --metadata=google-logging-enabled=true \
    --maintenance-policy=MIGRATE --service-account="${computeDefaultServiceAccount}" \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=squid \
    --image=cos-stable-85-13310-1041-38 \
    --image-project=cos-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=crawler-proxy-template \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --container-image="${DOCKER_PATH}" \
    --container-restart-policy=always \
    --labels=container-vm=cos-stable-85-13310-1041-38 \
    --reservation-affinity=any \
# create instance group
