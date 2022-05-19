#! /bin/sh
set -e

IP=$1
if [ "$IP" = "" ]; then
    echo "rotate_proxy.sh <IP> ip address is not provide."
    exit 1
fi
INS_GROUP=crawler-proxy-ins-group
VM_NAME=$(gcloud compute instances list --filter=name:crawler-proxy --format="value(name,EXTERNAL_IP)" | grep "$IP" | cut -f 1)

if [ "$VM_NAME" = "" ]; then
    echo "VM is not match, your ip is invalid."
    exit 1
fi

REGION=$(gcloud compute instance-groups list --filter=name:$INS_GROUP --format="value(LOCATION)")

echo "delete VM $VM_NAME at instance group $INS_GROUP($REGION)"
gcloud compute instance-groups managed delete-instances "$INS_GROUP" \
    --instances "$VM_NAME" --region "$REGION"

VM_SIZE=100

echo "resize VM size to $VM_SIZE"
gcloud compute instance-groups managed resize "$INS_GROUP" \
    --size "$VM_SIZE" --region "$REGION"
