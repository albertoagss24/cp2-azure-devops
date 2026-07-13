# main.tf - Config de Terraform, del proveedor de Azure y grupo de recursos.

terraform {
    required_version = ">= 1.9.0" # Versión mínima de Terraform requerida

    # Proveedores (plugins) que necesita esta configuración.
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm" # Proveedor oficial de Azure
            version = "~> 4.0" # Rama 4.x (cualquier versión 4.x)
        }
    }
}

# Configuración del proveedor de Azure
provider "azurerm" {
    features {} # Bloque obligatiorio en azurerm v4 (aunque vaya vacío)
    resource_provider_registrations = "none" # Desactiva el registro automático de resource providers
}

# Grupo de recursos: la "carpeta lógica" que agrupa todos los recursos del proyecto
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefijo}-rg" # Nombre del grupo
    location = var.localizacion # Región de Azure (swedencentral)
    tags     = var.etiquetas # Etiquetas comunes del proyecto
}