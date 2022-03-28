variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-east1"
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

variable "service_account" {
  type = string
}