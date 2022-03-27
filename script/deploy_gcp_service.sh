#! /bin/bash

set -e

read -r -e -p "Please enter project_id: " projectName
read -r -e -p "enter your proxy region ex:(asia-east1)" region
read -r -e -p "enter proxy vm number: " VM_NUM

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
# setting region array
regions=("${region}")
# create firewall rule
if [[ $(gcloud compute firewall-rules list --filter squid-fw) == "" ]] ; then
gcloud compute --project="${projectName}" firewall-rules create squid-fw \
    --direction=INGRESS --priority=1000 --network=crawler-proxy-vpc \
    --action=ALLOW --rules=tcp:3128 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16
fi
# create vm template
DOCKER_PATH=asia.gcr.io/${projectName}/crawler-proxy:latest
if [[ $(gcloud beta compute instance-templates list --filter crawler-proxy-preempt-template) == "" ]] ; then
    gcloud beta compute --project="${projectName}" instance-templates \
        create-with-container crawler-proxy-preempt-template --machine-type=e2-micro \
        --network=projects/"${projectName}"/global/networks/crawler-proxy-vpc \
        --network-tier=PREMIUM --metadata=google-logging-enabled=true \
        --maintenance-policy=TERMINATE \
        --preemptible \
        --service-account="${computeDefaultServiceAccount}" \
        --scopes=https://www.googleapis.com/auth/cloud-platform \
        --tags=squid-fw \
        --image=cos-stable-85-13310-1041-38 \
        --image-project=cos-cloud \
        --boot-disk-size=10GB \
        --boot-disk-type=pd-standard \
        --boot-disk-device-name=crawler-proxy-preempt-template \
        --no-shielded-secure-boot \
        --shielded-vtpm \
        --shielded-integrity-monitoring \
        --container-image="${DOCKER_PATH}" \
        --container-restart-policy=always \
        --labels=container-vm=cos-stable-85-13310-1041-38
fi
# create instance group by region
for region in "${regions[@]}"
do
    if [[ $(gcloud compute instance-groups managed list --filter "${region}"-crawler-proxy-pool) == "" ]] ; then
        echo "create instance group..."
        gcloud beta compute --project="${projectName}" instance-groups managed create "${region}"-crawler-proxy-pool \
            --template=crawler-proxy-preempt-template --size="${VM_NUM}" --region "${region}"
        gcloud beta compute --project "${projectName}" instance-groups managed set-named-ports "${region}"-crawler-proxy-pool \
            --region "${region}" --named-ports squid:3128
    else
        echo "instance group ${region} aleady exist!"
    fi
done
### create tcp proxy load balancer
# create health check
if [[ $(gcloud compute health-checks list --filter squid-tcp-health-check) == "" ]] ; then
    gcloud compute health-checks create tcp squid-tcp-health-check --port 3128
fi
# create backend service
if [[ $(gcloud compute backend-services list --filter squid-backend-service) == "" ]] ; then
    echo "create backend service..."
    gcloud compute backend-services create squid-backend-service \
        --global-health-checks \
        --global \
        --protocol TCP \
        --health-checks squid-tcp-health-check \
        --timeout 5m \
        --port-name squid
    for region in "${regions[@]}"
    do
        gcloud compute backend-services add-backend squid-backend-service \
            --global \
            --instance-group "${region}"-crawler-proxy-pool \
            --instance-group-region "${region}" \
            --balancing-mode CONNECTION \
            --max-connections-per-instance 1
    done
else
    echo "backend service already exist!"
fi
# create tcp proxy
if [[ $(gcloud compute target-tcp-proxies list --filter squid-tcp-lb-target-proxy) == "" ]] ; then
    echo "create tcp proxy..."
    gcloud compute target-tcp-proxies create squid-tcp-lb-target-proxy \
        --backend-service squid-backend-service \
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
        --ports 8085
else
    echo "forwarding rule already exist!"
fi