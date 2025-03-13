// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "external" "certificate" {
  program = ["bash", "create_certificate.sh"]
}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.product_family
  logical_product_service = var.product_service
  region                  = var.region
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.region

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "user_managed_identity" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/user_managed_identity/azurerm"
  version = "~> 1.0"

  user_assigned_identity_name = module.resource_names["user_assigned_identity"].minimal_random_suffix
  resource_group_name         = module.resource_group.name
  location                    = var.region

  tags = merge(var.tags, { resource_name = module.resource_names["user_assigned_identity"].standard })

  depends_on = [module.resource_group]
}

module "apim" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_management/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["api_management"].minimal_random_suffix
  resource_group_name = module.resource_group.name
  location            = var.region

  sku_name        = var.sku_name
  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email

  identity_type = "UserAssigned"
  identity_ids  = [module.user_managed_identity.id]

  public_network_access_enabled = var.public_network_access_enabled

  virtual_network_type = var.virtual_network_type

  tags = merge(var.tags, { resource_name = module.resource_names["api_management"].standard })

  depends_on = [module.user_managed_identity]
}

module "key_vault" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm"
  version = "~> 1.0"

  key_vault_name = module.resource_names["key_vault"].minimal_random_suffix
  resource_group = {
    name     = module.resource_group.name
    location = var.region
  }

  custom_tags = merge(var.tags, { resource_name = module.resource_names["key_vault"].standard })

  depends_on = [module.resource_group]
}

module "key_vault_secret" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault_secret/azurerm"
  version = "~> 1.0"

  key_vault_id = module.key_vault.key_vault_id
  name         = var.secret_name
  value        = data.external.certificate.result.pfx

  depends_on = [module.key_vault]
}

module "role_assignment" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  scope                = module.key_vault.key_vault_id
  principal_id         = module.user_managed_identity.principal_id
  role_definition_name = "Key Vault Secrets User"

  depends_on = [module.user_managed_identity, module.key_vault]
}

module "apim_certificate" {
  source = "../.."

  api_management_name = module.apim.api_management_name
  resource_group_name = module.resource_group.name

  name     = var.name
  data     = var.data
  password = var.password

  key_vault_secret_id          = "https://${module.key_vault.key_vault_name}.vault.azure.net/secrets/${module.key_vault_secret.name}"
  key_vault_identity_client_id = module.user_managed_identity.client_id

  depends_on = [module.apim, module.key_vault_secret, module.role_assignment]
}
