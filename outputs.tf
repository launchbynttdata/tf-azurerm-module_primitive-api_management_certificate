output "certificate_id" {
  description = "The Azure Resource ID of the API Management certificate"
  value       = azurerm_api_management_certificate.certificate.id
}

output "certificate_name" {
  description = "The resource name of the API Management certificate"
  value       = azurerm_api_management_certificate.certificate.name
}

output "certificate_thumbprint" {
  description = "The thumbprint of the API Management certificate"
  value       = azurerm_api_management_certificate.certificate.thumbprint
}
