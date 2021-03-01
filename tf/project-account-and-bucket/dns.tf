resource "google_dns_managed_zone" "tas-srt" {
  name        = "tas-srt"
  dns_name    = "${var.zone_address}."
  description = "Zone for tas-srt project"
  labels = {
    environment = var.env
  }

  depends_on = [google_project_service.dns]
}

data "aws_route53_zone" "parent_zone" {
  name = "engineerbetter.com."
}

resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.parent_zone.zone_id
  name    = var.zone_address
  type    = "NS"
  ttl     = "300"
  records = google_dns_managed_zone.tas-srt.name_servers
}
