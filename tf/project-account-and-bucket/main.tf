provider "google" {
  project = var.project_id
  region  = "europe-west2"
}

data "google_project" "project" {}

resource "google_service_account" "ci_bot" {
  account_id   = "ci-bot"
  display_name = "ci-bot"
  description  = "To be used by CI"
}

resource "google_project_iam_member" "owner" {
  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.ci_bot.email}"
}

resource "google_project_iam_member" "compute_admin" {
  role   = "roles/compute.admin"
  member = "serviceAccount:${google_service_account.ci_bot.email}"
}

resource "google_project_iam_member" "storage_admin" {
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ci_bot.email}"
}

resource "google_service_account_key" "ci_bot_key" {
  service_account_id = google_service_account.ci_bot.name
}

resource "google_project_service" "dns" {
  project                    = var.project_id
  service                    = "dns.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "compute" {
  project                    = var.project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "networking" {
  project                    = var.project_id
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "stackdriver" {
  project                    = var.project_id
  service                    = "stackdriver.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "monitoring" {
  project                    = var.project_id
  service                    = "monitoring.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "logging" {
  project                    = var.project_id
  service                    = "logging.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudresourcemanager" {
  project                    = var.project_id
  service                    = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudtrace" {
  project                    = var.project_id
  service                    = "cloudtrace.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "iamcredentials" {
  project                    = var.project_id
  service                    = "iamcredentials.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "storage" {
  project                    = var.project_id
  service                    = "storage.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "iam" {
  project                    = var.project_id
  service                    = "iam.googleapis.com"
  disable_dependent_services = true
}

data "google_compute_zones" "available" {
  depends_on = [
    google_project_service.compute,
  ]
}
