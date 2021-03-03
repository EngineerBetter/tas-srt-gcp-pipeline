terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    aws = {
      source = "hashicorp/aws"
    }
    acme = {
      source = "terraform-providers/acme"
    }
  }
  required_version = ">= 0.13"
}
