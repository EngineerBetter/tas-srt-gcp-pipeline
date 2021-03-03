provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
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
    "*.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "*.apps.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "*.ws.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "doppler.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "loggregator.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "ssh.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "opsmanager.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "tcp.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}"
  ]

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT             = var.project_id
      GCE_PROPAGATION_TIMEOUT = "600"
    }
  }
}
