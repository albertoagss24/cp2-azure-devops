# recursos.tf - Recursos de Azure

# Registro privado de imágenes de contenedores. Las apps de Podman y Kubernetes descargan las imágenes de aquí.
resource "azurerm_container_registry" "acr" {
    name                = var.acr_nombre                     # Nombre único global, solo minúsculas/números
    resource_group_name = azurerm_resource_group.rg.name     # Grupo de recursos donde se crea
    location            = azurerm_resource_group.rg.location # Hereda la región del grupo (swedencentral)

    sku           = var.acr_sku                              # Nivel del registro (Basic: el más económico)
    admin_enabled = true                                     # Habilita usuario+contraseña de admin para 'podman login'

    tags = var.etiquetas                                     # Etiquetas comunes del proyecto
}