module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = var.container_image
    env = [
      for k, v in var.DOCKER_IMAGE_ENV :
      {
        name  = k
        value = v
      }
    ]
  }
  restart_policy = "Always"
}


module "mig_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 7.3"
  network = var.network
  service_account = {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud_debugger",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
  machine_type = var.machine_type
  disk_size_gb = 10
  disk_type    = "pd-balanced"
  access_config = [{
    nat_ip       = ""
    network_tier = "PREMIUM"
  }]
  name_prefix          = "${var.vm_name}-template"
  source_image_family  = "cos-stable"
  source_image_project = "cos-cloud"
  source_image         = reverse(split("/", module.gce-container.source_image))[0]
  metadata             = { "gce-container-declaration" = module.gce-container.metadata_value }
  preemptible          = true
}

resource "google_compute_region_instance_group_manager" "default" {
  name   = "${var.vm_name}-ins-group"
  region = var.region
  version {
    instance_template = module.mig_template.self_link
    name              = "primary"
  }
  base_instance_name = var.vm_name

  target_size = var.target_size

  named_port {
    name = var.named_port.name
    port = var.named_port.port
  }

}
