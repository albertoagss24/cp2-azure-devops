# outputs.tf - Valores que necesitaremos tras crear la infraestructura

output "acr_login_server" {
    description = "Servidor de login del ACR."
    value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
    description = "Usuario admin del ACR para 'podman login'."
    value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
    description = "Contraseña admin del ACR (se oculta en la salida, usar 'terraform output -raw acr_admin_password')."
    value       = azurerm_container_registry.acr.admin_password
    sensitive   = true
}

output "resource_group_name" {
    description = "Nombre del grupo de recursos creado."
    value       = azurerm_resource_group.rg.name
}