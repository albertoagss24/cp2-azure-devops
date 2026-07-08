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

# Máquina virtual (VM)

variable "vm_tamano" {
    description = "Tamaño (SKU) de la VM. B2ats_v2 = 2 vCPU burstable, free tier de Student, arquitectura amd64."
    type        = string
    default     = "Standard_B2ats_v2"
}

variable "vm_usuario" {
  description = "Usuario administrador de la VM (acceso por SSH)."
  type        = string
  default     = "azureuser"
}

variable "ssh_clave_publica_path" {
  description = "Ruta a la clave SSH publica que se instalara en la VM."
  type        = string
  default     = "~/.ssh/cp2_key.pub"
}

# Clúster AKS (Azure Kubernetes Service)

variable "aks_dns_prefix" {
    description = "Prefijo DNS del cluster AKS."
    type        = string
    default     = "cp2unir-aks"
}

variable "aks_node_count" {
    description = "Número de nodos worker. El enunciado exige 1."
    type        = number
    default     = 1
}

variable "aks_node_size" {
    description = "Tamaño de los nodos AKS. D2s_v3 = 2 vCPU, (VM 2 + AKS 2 = 4 <= 6 de la cuota Student)"
    type        = string
    default     = "Standard_D2s_v3"
}