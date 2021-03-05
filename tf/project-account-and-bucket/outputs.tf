output "project_number" {
  value = data.google_project.project.number
}

output "gcp_credentials_json" {
  value     = base64decode(google_service_account_key.ci_bot_key.private_key)
  sensitive = true
}

output "zone_name" {
  value = google_dns_managed_zone.tas-srt.name
}

output "zone_address" {
  value = trimsuffix(google_dns_managed_zone.tas-srt.dns_name, ".")
}

output "available_zones" {
  value = data.google_compute_zones.available.names
}

output "ssl_key" {
  value     = acme_certificate.apps.private_key_pem
  sensitive = true
}

output "ssl_cert" {
  value = acme_certificate.apps.certificate_pem
}

output "ssl_issuer" {
  value = acme_certificate.apps.issuer_pem
}
output "gcp_service_account_email" {
  value = google_service_account.ci_bot.email
}

output "credhub_encryption_key" {
  value     = random_string.credhub_encryption_key.result
  sensitive = true
}
