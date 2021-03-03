provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

locals {
  trimmed_zone = trimsuffix(google_dns_managed_zone.tas-srt.dns_name, ".")
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "${var.env}-tas@engineerbetter.com"
}

resource "acme_certificate" "apps" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = google_dns_managed_zone.tas-srt.dns_name
  subject_alternative_names = [
    "*.sys.${var.env}.${local.trimmed_zone}",
    "*.apps.${var.env}.${local.trimmed_zone}",
    "*.ws.${var.env}.${local.trimmed_zone}",
    "doppler.sys.${var.env}.${local.trimmed_zone}",
    "loggregator.sys.${var.env}.${local.trimmed_zone}",
    "ssh.sys.${var.env}.${local.trimmed_zone}",
    "opsmanager.${var.env}.${local.trimmed_zone}",
    "tcp.${var.env}.${local.trimmed_zone}"
  ]

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT             = var.project_id
      GCE_PROPAGATION_TIMEOUT = "600"
    }
  }
}
