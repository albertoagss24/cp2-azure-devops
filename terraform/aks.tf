# aks.tf - Cluster de Kubernetes gestionado (AKS) e integración con el ACR.

# 1 - El clúster de Kubernetes gestionado (AKS).
resource "azurerm_kubernetes_cluster" "aks" {
    name                = "${var.prefijo}-aks"               # Nombre del clúster en Azure
    resource_group_name = azurerm_resource_group.rg.name     # Grupo de recursos donde se crea
    location            = azurerm_resource_group.rg.location # Hereda la región (swedencentral)
    dns_prefix          = var.aks_dns_prefix                 # Prefijo DNS del API server del clúster
    sku_tier            = "Free"                             # Nivel gratuito: no factura el plano de control

    # Grupo de nodos worker: las máquinas donde se ejecutan los pods.
    default_node_pool {
        name       = "default"          # Nombre del grupo de nodos
        node_count = var.aks_node_count # Número de nodos (el enunciado exige 1)
        vm_size    = var.aks_node_size  # Tamaño de cada nodo (Standard_D2s_v3 = 2 vCPU)
    }

    # Identidad gestionada del clúster: credencial automática administrada por Azure, sin contraseñas. Se usa para autenticarse ante otros servicios.
    identity {
        type = "SystemAssigned"
    }

    tags = var.etiquetas # Etiquetas comunes del proyecto
}

# 2 - Asignación del rol: integración AKS > ACR
# Permisos para que el cluster AKS pueda hacer pull de imágenes desde el ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
    scope                            = azurerm_container_registry.acr.id                            # Recurso sobre el que aplica: el ACR
    role_definition_name             = "AcrPull"                                                    # Rol: sólo lectura/descarga de imágenes
    principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    skip_service_principal_aad_check = true                                                         # Evita un error de validación cuando la identidad se acaba de crear
}