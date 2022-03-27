variable "project_id" {
  type        = string
}

variable "network" {
  description = "The name or self_link of the network to attach this interface to."
  default     = ""
}

variable "vm_name" {
  description = "The vm name that vm group to deploy."
}

variable "container_image" {
    type = string
}

variable "DOCKER_IMAGE_ENV" {
  type = map(string)
  default = {}
}
variable "service_account" {
  type = object({
    email  = string
    scopes = set(string)
  })
  default = {
    email = "vpon-web-crawler@gen-job-dev.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud_debugger",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "machine_type" {
  type = string  
}

variable "named_port" {
  type = map
}
