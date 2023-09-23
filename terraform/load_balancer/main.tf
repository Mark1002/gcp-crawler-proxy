resource "google_compute_target_tcp_proxy" "default" {
  name            = var.lb_name
  backend_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "${var.lb_name}-backend-service"
  protocol    = "TCP"
  port_name   = "squid"
  timeout_sec = 10

  backend {
    group           = var.vm_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    max_utilization = 1.0
  }

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  name               = "${var.lb_name}-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = var.health_check_port
  }
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "crawler-proxy-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "8085"
  target                = google_compute_target_tcp_proxy.default.id
}
