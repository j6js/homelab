resource "cloudflare_r2_bucket" "secure1_vault_bucket" {
  account_id = data.sops_file.cloudflare.data["account_id"]
  name = "vault-storage"
  location = "apac"
  storage_class = "Standard"
}