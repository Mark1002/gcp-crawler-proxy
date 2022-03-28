terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

module "network" {
  source = "./network"
  network_name = var.network_name
  firewall_name = var.firewall_name
}

module "vm_group" {
  source = "./vm_group"
  project_id = var.project_id
  vm_name = "crawler-proxy"
  machine_type = "e2-micro"
  region = var.region
  target_size = 5
  named_port = var.named_port
  container_image = "asia.gcr.io/${var.project_id}/crawler-proxy:latest"
  network = module.network.network_name
  service_account = var.service_account
}

module "load_balancer" {
  source = "./load_balancer"
  lb_name = "crawler-proxy"
  vm_group = module.vm_group.vm_group
  health_check_port = var.named_port.port
}
