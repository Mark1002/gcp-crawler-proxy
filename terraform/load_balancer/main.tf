resource "google_compute_target_tcp_proxy" "default" {
  name            = var.lb_name
  backend_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "${var.lb_name}-backend-service"
  protocol    = "TCP"
  port_name = "squid"
  timeout_sec = 10

  backend {
    group          = var.vm_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name               = "${var.lb_name}-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "3128"
  }
}
