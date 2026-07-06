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

output "vm_ip_publica" {
    description = "IP publica de la VM (para SSH y para acceder a la web por HTTPS)."
    value       = azurerm_public_ip.pip.ip_address
}

output "vm_usuario" {
    description = "Usuario administrador de la VM."
    value       = azurerm_linux_virtual_machine.vm.admin_username
}
