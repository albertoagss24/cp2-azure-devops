variable "prefijo" {
    description = "Prefijo común para nombrar los recursos (rg, vm, aks...). Sólo minúsculas y guiones."
    type        = string
    default     = "cp2"
}

variable "localizacion" {
    description = "Región de Azure donde se desplegarán los recursos. Usamos swedencentral en la cuenta student"
    type        = string
    default     = "swedencentral"
}

variable "etiquetas" {
    description = "Etiquetas aplicadas a todos los recursos para identificarlos y filtrarlos."
    type        = map(string)
    default     = {
        environment = "casopractico2"
        proyecto    = "cp2unir"
        gestionado  = "terraform"
    }
}

# --- ACR (Azure Container Registry) ---

variable "acr_nombre" {
    description = "Nombre del Azure Container Registry (ACR). Debe ser único a nivel global y sólo puede contener minúsculas y números."
    type        = string
    default     = "cp2uniracr"

    # Validación del nombre del ACR: minúsculas y números, entre 5 y 50 caracteres
    validation {
        condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_nombre))
        error_message = "El nombre del ACR solo admite minúsculas y números, entre 5 y 50 caracteres."
    }
}

variable "acr_sku" {
    description = "SKU del Azure Container Registry (ACR)."
    type        = string
    default     = "Basic"
}