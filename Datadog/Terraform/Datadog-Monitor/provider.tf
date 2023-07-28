provider "datadog" {
  api_key = data.vault_generic_secret.datadog_access_key.data["API_KEY"]
  app_key = data.vault_generic_secret.datadog_access_key.data["APP_KEY"]
  api_url = var.datadog_api_url
}

provider "vault" {
  address = var.vault_url

  auth_login_userpass {
    username = var.vault_user
    password = var.vault_pass
  }
}

data "vault_generic_secret" "datadog_access_key" {
  path = var.datadog_access_key_path
}