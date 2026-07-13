# outputs.tf - Valores que Terraform devuelve tras crear la infraestructura
# Los usamos en pasos posteriores: login y push al ACR, conexión a la VM, etc.

# URL del registro. Se usa para etiquetar (tag) y subir/descargar imágenes.
output "acr_login_server" {
    description = "Servidor de login del ACR."
    value       = azurerm_container_registry.acr.login_server
}

# Usuario administrador del ACR, necesario para 'podman login'.
output "acr_admin_username" {
    description = "Usuario admin del ACR para 'podman login'."
    value       = azurerm_container_registry.acr.admin_username
}

# Contraseña del ACR. Marcada como sensible: Terraform la oculta en pantalla.
output "acr_admin_password" {
    description = "Contraseña admin del ACR (se oculta en la salida, usar 'terraform output -raw acr_admin_password')."
    value       = azurerm_container_registry.acr.admin_password
    sensitive   = true # No se muestra en la salida por seguridad
}

# Nombre del grupo de recursos (cómodo para comandos de 'az' y 'kubectl').
output "resource_group_name" {
    description = "Nombre del grupo de recursos creado."
    value       = azurerm_resource_group.rg.name
}

# IP pública de la VM: se usa para conectar por SSH y para acceder a la web (HTTPS).
output "vm_ip_publica" {
    description = "IP publica de la VM (para SSH y para acceder a la web por HTTPS)."
    value       = azurerm_public_ip.pip.ip_address
}

# Usuario administrador de la VM (para las conexiones SSH y el inventario de Ansible).
output "vm_usuario" {
    description = "Usuario administrador de la VM."
    value       = azurerm_linux_virtual_machine.vm.admin_username
}

# Nombre del clúster AKS: se usa en 'az aks get-credentials' para obtener el kubeconfig.
output "aks_nombre" {
    description = "Nombre del cluster AKS."
    value       = azurerm_kubernetes_cluster.aks.name
}