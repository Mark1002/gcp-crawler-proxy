terraform {
  backend "gcs" {}
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

module "network" {
  source = "./network"
}
