#! /bin/bash

## set -ex

read -r -e -p "Please enter project_id: " projectName
gcloud config set compute/region asia-east1
# Set project environment
gcloud config set project "${projectName}"
# get compute default service account
computeDefaultServiceAccount="$(gcloud iam service-accounts list --filter='Compute Engine default service account' |grep -oE '[0-9]+-compute@developer\.gserviceaccount\.com')"
# create vpc network
if [[ $(gcloud compute networks list --filter crawler-proxy-vpc) == "" ]] ; then
    gcloud compute networks create crawler-proxy-vpc \
        --project="${projectName}" --description='for crawler-proxy' \
        --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional
else
    echo "vpc network crawler-proxy-vpc aleady exist!"
fi
# create firewall rule
if [[ $(gcloud compute firewall-rules list --filter squid-fw) == "" ]] ; then
gcloud compute --project="${projectName}" firewall-rules create squid-fw \
    --direction=INGRESS --priority=1000 --network=crawler-proxy-vpc \
    --action=ALLOW --rules=tcp:3128 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16
fi
# create vm template
DOCKER_PATH=asia.gcr.io/${projectName}/crawler-proxy:latest
if [[ $(gcloud beta compute instance-templates list --filter crawler-proxy-template) == "" ]] ; then
    gcloud beta compute --project="${projectName}" instance-templates \
        create-with-container crawler-proxy-template --machine-type=e2-micro \
        --network=projects/"${projectName}"/global/networks/crawler-proxy-vpc \
        --network-tier=PREMIUM --metadata=google-logging-enabled=true \
        --maintenance-policy=MIGRATE --service-account="${computeDefaultServiceAccount}" \
        --scopes=https://www.googleapis.com/auth/cloud-platform \
        --tags=squid-fw \
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
        --labels=container-vm=cos-stable-85-13310-1041-38
fi
# create instance group
if [[ $(gcloud compute instance-groups managed list --filter crawler-proxy-group1) == "" ]] ; then
    echo "create instance group..."
    gcloud beta compute --project="${projectName}" instance-groups managed create crawler-proxy-group1 \
        --base-instance-name=crawler-proxy-group1 --template=crawler-proxy-template --size=5 \
        --zones=asia-east1-a,asia-east1-b,asia-east1-c --instance-redistribution-type=PROACTIVE
    gcloud beta compute --project "${projectName}" instance-groups managed set-named-ports crawler-proxy-group1 \
        --region "asia-east1" --named-ports squid:3128
else
    echo "instance group aleady exist!"
fi
### create tcp proxy load balancer
# create health check
if [[ $(gcloud compute health-checks list --filter squid-tcp-health-check) == "" ]] ; then
    gcloud compute health-checks create tcp squid-tcp-health-check --port 3128
fi
# create backend service
if [[ $(gcloud compute backend-services list --filter squid-tcp-lb) == "" ]] ; then
    echo "create backend service..."
    gcloud compute backend-services create squid-tcp-lb \
        --global-health-checks \
        --global \
        --protocol TCP \
        --health-checks squid-tcp-health-check \
        --timeout 5m \
        --port-name squid
    gcloud compute backend-services add-backend squid-tcp-lb \
        --global \
        --instance-group crawler-proxy-group1 \
        --instance-group-region asia-east1 \
        --balancing-mode UTILIZATION \
        --max-utilization 0.8
else
    echo "backend service already exist!"
fi
# create tcp proxy
if [[ $(gcloud compute target-tcp-proxies list --filter squid-tcp-lb-target-proxy) == "" ]] ; then
    echo "create tcp proxy..."
    gcloud compute target-tcp-proxies create squid-tcp-lb-target-proxy \
        --backend-service squid-tcp-lb \
        --proxy-header NONE
else
    echo "tcp proxy already exist!"
fi
## static external IP
loadBlancerIPName=crawler-lb-ip
### create static ip if not exist
if [[ $(gcloud compute addresses list|grep "${loadBlancerIPName}") == "" ]] ; then
    echo "create static ip..."
    gcloud compute addresses create ${loadBlancerIPName} --project="${projectName}" --global
else
    echo "static ip already exist!"
fi
# forwarding rule
if [[ $(gcloud compute forwarding-rules list --filter squid-tcp-lb-ipv4-forwarding-rule) == "" ]] ; then
    echo "create forwarding rule..."
    gcloud beta compute forwarding-rules create squid-tcp-lb-ipv4-forwarding-rule \
        --global \
        --target-tcp-proxy squid-tcp-lb-target-proxy \
        --address ${loadBlancerIPName} \
        --ports 110
else
     echo "forwarding rule already exist!"
fi