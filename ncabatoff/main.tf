provider "google" {
  project = "ncabatoff-vault-testing"
  region  = "us-east4"
  zone    = "us-east4-c"
}

module "vault" {
  source         = "./.."
  project_id     = "ncabatoff-vault-testing"
  region         = "us-east4"
  kms_keyring    = "ncabatoff_kms_keyring1"
  kms_crypto_key = "ncabatoff_kms_crypto_key8"
  vault_min_num_servers = "3"
  vault_instance_tags = ["ncabatoff-vault"]
  vault_bin_bucket = "ncabatoff-vault-binaries"
  service_account_project_additional_iam_roles = ["roles/compute.networkAdmin"]
  vault_log_level = "trace"
}

output "vault_addr" {
  value = module.vault.vault_addr
}