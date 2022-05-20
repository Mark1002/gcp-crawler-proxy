#!/bin/sh
set -e

gcloud config set project "${PROJECT_ID}"

IMAGE_NAME="proxymanager"
VERSION="latest"
MEMORY="512Mi"
CPU_COUNT="1"
REGION="asia-east1"
SERVICE="proxymanager"
CONTAINER_PORT="8080"

IMAGE="${REGION}"-docker.pkg.dev/"${PROJECT_ID}"/cloud-run-source-deploy/${IMAGE_NAME}:${VERSION}

gcloud builds submit \
--tag "$IMAGE" \
--project "${PROJECT_ID}"

gcloud run deploy "$SERVICE" \
    --port "$CONTAINER_PORT" \
    --image "$IMAGE" \
    --memory ${MEMORY} \
    --cpu ${CPU_COUNT} \
    --region ${REGION} \
    --project "${PROJECT_ID}" \
    --set-env-vars "$(cat .env | tr '\n' ',')" \
    --platform managed \
    --no-cpu-throttling \
    --allow-unauthenticated
