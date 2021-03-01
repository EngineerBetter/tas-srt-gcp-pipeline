terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
}
