terraform {
    required_version = ">= 1.9.0"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 4.0"
        }
    }
}

provider "azurerm" {
    features {}
    resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "rg" {
    name     = "${var.prefijo}-rg"
    location = var.localizacion
    tags     = var.etiquetas
}