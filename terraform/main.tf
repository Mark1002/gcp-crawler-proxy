terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
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
  named_port = var.named_port
  container_image = "asia.gcr.io/${var.project_id}/crawler-proxy:latest"
  network = module.network.network_name
}

module "load_balancer" {
  source = "./load_balancer"
  lb_name = "crawler-proxy"
  vm_group = module.vm_group.vm_group
}
