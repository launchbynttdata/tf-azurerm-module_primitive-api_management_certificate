resource "azurerm_api_management_certificate" "certificate" {
  name                = var.name
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name

  data     = var.data
  password = var.password

  key_vault_secret_id          = var.key_vault_secret_id
  key_vault_identity_client_id = var.key_vault_identity_client_id
}
