resource "random_string" "credhub_encryption_key" {
  length  = 20
  special = false
}

resource "random_string" "opsman_password" {
  length  = 16
  special = false
}

resource "random_string" "opsman_decryption_passphrase" {
  length  = 30
  special = false
}

resource "random_string" "hsm_password" {
  length  = 20
  special = false
}
