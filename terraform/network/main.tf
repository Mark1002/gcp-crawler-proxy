resource "google_compute_network" "vpc_network" {
  name = var.network_name
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "fw" {
  name = var.firewall_name
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "tcp"
    ports = ["3128"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

}