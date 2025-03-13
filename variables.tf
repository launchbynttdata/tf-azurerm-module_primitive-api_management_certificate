variable "resource_group_name" {
  type        = string
  description = "name of the resource group where the APIM exists"
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,50}$", var.resource_group_name))
    error_message = "The resource group name can only contain alphanumeric characters and dashes and must be between 1 and 50 characters long."
  }
}

variable "api_management_name" {
  type        = string
  description = "name of the APIM in which this certificate will de deployed"
  default     = null
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,50}$", var.api_management_name))
    error_message = "The APIM name can only contain alphanumeric characters and dashes and must be between 1 and 50 characters long."
  }
}

variable "name" {
  type        = string
  description = "name of the certificate"
  default     = null
  validation {
    condition     = var.name == null || can(regex("^[a-zA-Z0-9-]{1,50}$", var.name))
    error_message = "The certificate name can only contain alphanumeric characters and dashes and must be between 1 and 50 characters long."
  }
}

variable "data" {
  type        = string
  description = "base64 encoded pfx bundle containing the certificate"
  default     = null
  validation {
    condition     = var.data == null || can(regex("^[a-zA-Z0-9+/=]+$", var.data))
    error_message = "the certificate data must be a valid base64 encoded string"
  }
}

variable "password" {
  type        = string
  description = "the password used with the pfx bundle containing the certificate"
  default     = null
}

# every 'certificate' object in key vault has an underlying 'secret' object of the same name containing the base64-encoded pfx bundle
variable "key_vault_secret_id" {
  type        = string
  description = "key vault secret identifier containing the certificate"
  default     = null
  validation {
    condition     = var.key_vault_secret_id == null || can(regex("^https://.*/secrets/.*$", var.key_vault_secret_id))
    error_message = "the key vault secret id must be a valid URL"
  }
}

variable "key_vault_identity_client_id" {
  type        = string
  description = "the user assigned managed identity to retrieve the certificate with. defaults to the system identity of the APIM"
  default     = null
  validation {
    condition     = var.key_vault_identity_client_id == null || can(regex("^[a-fA-F0-9-]+$", var.key_vault_identity_client_id))
    error_message = "the key vault identity client ID must be a valid GUID"
  }
}
