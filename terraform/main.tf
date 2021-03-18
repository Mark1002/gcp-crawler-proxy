terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "3.60.0"
        }
    }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  auto_create_subnetworks = "true"
}