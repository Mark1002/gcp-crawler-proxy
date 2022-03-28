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
  type = string
}

variable "region" {
  type = string
}

variable "machine_type" {
  type = string  
}

variable "named_port" {
  type = map
}

variable "target_size" {
  type = number
}