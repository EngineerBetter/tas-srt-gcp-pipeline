resource "random_string" "credhub_encryption_key" {
  length  = 16
  special = false
}
