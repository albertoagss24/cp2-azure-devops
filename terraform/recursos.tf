# recursos.tf - Recursos de Azure

# Azure Container Registry (ACR)
# Registro privado de imágenes de contenedores. Las apps de Podman y Kubernetes descargan las imágenes de aquí.

resource "azurerm_container_registry" "acr" {
    name                = var.acr_nombre
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location

    sku           = var.acr_sku
    admin_enabled = true

    tags = var.etiquetas
}