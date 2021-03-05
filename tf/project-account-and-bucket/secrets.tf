resource "random_string" "credhub_encryption_key" {
  length  = 16
  special = false
}


resource "random_string" "opsman_password" {
  length  = 16
  special = false
}
