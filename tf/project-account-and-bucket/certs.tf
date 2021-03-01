resource "tls_private_key" "lb-key" {
  algorithm   = "RSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "lb-cert" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.lb-key.private_key_pem

  subject {
    common_name  = google_dns_managed_zone.tas-srt.dns_name
    organization = "foobar"
  }

  dns_names = [
    "*.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "*.apps.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "*.ws.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "doppler.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "loggregator.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "ssh.sys.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}",
    "tcp.${var.env}.${google_dns_managed_zone.tas-srt.dns_name}"
  ]

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
