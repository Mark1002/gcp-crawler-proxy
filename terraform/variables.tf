variable "project_id" {
  type = string
  default = "gen-job-dev"
}

variable "region" {
  type    = string
  default = "asia-east1"
}

variable "zone" {
  type    = string
  default = "asia-east1-b"
}

variable "network_name" {
  type = string
  default = "crawler-proxy"
}

variable "firewall_name" {
  type = string
  default = "crawler-proxy-fw"
}

variable "named_port" {
  type = map
  default = {
    name = "squid"
    port = 3128
  }
}
