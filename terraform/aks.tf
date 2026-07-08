# Cluster AKS
resource "azurerm_kubernetes_cluster" "aks" {
    name                = "${var.prefijo}-aks"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    dns_prefix          = var.aks_dns_prefix
    sku_tier            = "Free"

    default_node_pool {
        name       = "default"
        node_count = var.aks_node_count
        vm_size    = var.aks_node_size
    }

    identity {
        type = "SystemAssigned"
    }

    tags = var.etiquetas
}

# Permisos para que el cluster AKS pueda hacer pull de imágenes desde el ACR

resource "azurerm_role_assignment" "aks_acr_pull" {
    scope                            = azurerm_container_registry.acr.id
    role_definition_name             = "AcrPull"
    principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    skip_service_principal_aad_check = true
}