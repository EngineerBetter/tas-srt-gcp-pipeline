variable "project_id" {
  description = "The ID of the project in which to create a service account"
}

variable "parent_domain" {
  type        = string
  description = "Parent domain for the DNS zone"
}

variable "zone_address" {
  type        = string
  description = "DNS zone address"
}

variable "env" {}
