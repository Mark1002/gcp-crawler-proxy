terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source = "./network"
  network_name = var.network_name
  firewall_name = var.firewall_name
}

module "instances" {
  source = "./instances"
  project_id = var.project_id
  template_name = var.template_name
  network_name = var.network_name

  depends_on = [
    module.network
  ]  
}