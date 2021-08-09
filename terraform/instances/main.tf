locals {
  create_vm_template_command = <<EOF
DOCKER_PATH=asia.gcr.io/$project_id/crawler-proxy:latest
computeDefaultServiceAccount="$(gcloud iam service-accounts list --filter='Compute Engine default service account' |grep -oE '[0-9]+-compute@developer\.gserviceaccount\.com')"
gcloud beta compute --project=$project_id instance-templates \
    create-with-container $template_name --machine-type=e2-micro \
    --network=projects/$project_id/global/networks/$network_name \
    --network-tier=PREMIUM --metadata=google-logging-enabled=true \
    --maintenance-policy=TERMINATE \
    --preemptible \
    --service-account=$computeDefaultServiceAccount \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=squid-fw \
    --image=cos-stable-85-13310-1041-38 \
    --image-project=cos-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=$template_name \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --container-image=$DOCKER_PATH \
    --container-restart-policy=always \
    --labels=container-vm=cos-stable-85-13310-1041-38
EOF
}
resource "null_resource" "vm_template" {
  triggers = {
      vm_template = local.create_vm_template_command
  }
  provisioner "local-exec" {
    command = local.create_vm_template_command
    environment = {
      project_id = var.project_id
      template_name = var.template_name
      network_name = var.network_name
    }
  }
}