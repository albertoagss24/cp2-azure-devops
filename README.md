# Caso Práctico 2 — Despliegues automatizados en Azure

Despliegue, **íntegramente mediante código**, de un entorno cloud en Microsoft Azure
utilizando herramientas DevOps. Toda la infraestructura se crea con **Terraform** y toda
la configuración se realiza con **Ansible**, sin pasos manuales en el portal de Azure.

## Arquitectura

| Pieza | Servicio de Azure | Herramienta |
|-------|-------------------|-------------|
| Registro privado de imágenes | Azure Container Registry (ACR) | Terraform |
| App web en contenedor (HTTPS + autenticación, servicio systemd) | Máquina virtual Linux + Podman | Terraform + Ansible |
| Clúster de Kubernetes gestionado (1 nodo) | Azure Kubernetes Service (AKS) | Terraform |
| App con almacenamiento persistente (WordPress + MySQL) | AKS + PVC | Ansible |

El **ACR** es la pieza central: tanto la aplicación de la VM como la de Kubernetes
descargan de él sus imágenes.

## Estructura del repositorio

    .
    ├── terraform/          # Infraestructura como código (ACR, red + VM, AKS)
    │   ├── main.tf         # Proveedor de Azure y grupo de recursos
    │   ├── vars.tf         # Variables de entrada
    │   ├── recursos.tf     # Azure Container Registry
    │   ├── vm.tf           # Red y máquina virtual Linux
    │   ├── aks.tf          # Clúster AKS e integración con el ACR
    │   └── outputs.tf      # Salidas (IP, credenciales del ACR, etc.)
    ├── ansible/            # Gestión de la configuración
    │   ├── ansible.cfg     # Configuración local de Ansible
    │   ├── hosts           # Inventario (nodo gestionado: la VM)
    │   ├── deploy.sh       # Ejecuta el playbook de Podman con las credenciales del ACR
    │   ├── playbook.yml    # Despliega la app web en Podman sobre la VM
    │   ├── playbook_wordpress.yml  # Despliega WordPress + MySQL en AKS
    │   └── k8s/            # Manifiestos de Kubernetes (PVC, Deployments, Services)
    ├── app-podman/         # Imagen de la app web de la VM
    │   ├── Dockerfile      # Nginx + certificado autofirmado + htpasswd
    │   ├── nginx.conf      # Configuración HTTPS + autenticación básica
    │   └── html/index.html # Contenido web
    ├── LICENSE             # Licencia MIT
    └── README.md

## Requisitos previos

Nodo de control con Linux (se ha usado Ubuntu sobre WSL2) y las herramientas:

- Azure CLI (`az`), Terraform (>= 1.9), Ansible (>= 2.12), Podman, kubectl y Git.
- Colecciones de Ansible: `containers.podman` y `kubernetes.core` (+ librería `kubernetes` de Python).
- Un par de claves SSH (por defecto en `~/.ssh/cp2_key`).
- Cuenta **Azure for Students**. Región **swedencentral** (West Europe está bloqueada);
  límite de 6 vCPU por región; AKS con `sku_tier = "Free"`.

## Despliegue

### 1. Autenticación en Azure

    az login
    export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
    az provider register --namespace Microsoft.ContainerRegistry
    az provider register --namespace Microsoft.Compute
    az provider register --namespace Microsoft.Network
    az provider register --namespace Microsoft.ContainerService

### 2. Crear la infraestructura (Terraform)

    cd terraform
    terraform init
    terraform plan
    terraform apply

Crea el grupo de recursos, el ACR, la red + máquina virtual y el clúster AKS.

### 3. Construir y subir la imagen de la app web al ACR

    ACR=$(terraform output -raw acr_login_server)
    podman login "$ACR" \
      -u "$(terraform output -raw acr_admin_username)" \
      -p "$(terraform output -raw acr_admin_password)"

    cd ../app-podman
    podman build -t "$ACR/web-podman-nginx:casopractico2" .
    podman push  "$ACR/web-podman-nginx:casopractico2"

### 4. Configurar la VM con Ansible (app web en Podman)

Actualiza la IP de la VM en `ansible/hosts` (`terraform output vm_ip_publica`) y ejecuta:

    cd ../ansible
    ansible-galaxy collection install containers.podman
    ./deploy.sh

Verificación (401 sin credenciales, 200 con `alumno:unir2026`):

    curl -k -I https://<IP_VM>/
    curl -k -u alumno:unir2026 https://<IP_VM>/

### 5. Desplegar WordPress + MySQL en AKS (app con persistencia)

    az aks get-credentials --resource-group cp2-rg --name cp2-aks
    ansible-galaxy collection install kubernetes.core
    pip install kubernetes
    ansible-playbook playbook_wordpress.yml

    kubectl get pods
    kubectl get pvc                 # PVC en estado Bound
    kubectl get svc wordpress       # EXTERNAL-IP para acceder desde el navegador

## Apagar / encender (ahorro de crédito)

    # Apagar (deja de facturar el cómputo; el ACR se mantiene)
    az aks stop      --resource-group cp2-rg --name cp2-aks
    az vm deallocate --resource-group cp2-rg --name cp2-vm

    # Encender
    az aks start --resource-group cp2-rg --name cp2-aks
    az vm start  --resource-group cp2-rg --name cp2-vm

## Destruir toda la infraestructura

    cd terraform
    terraform destroy

## Notas de seguridad

- El estado de Terraform (`*.tfstate`), las claves SSH y las credenciales no se versionan
  (ver `.gitignore`). Las contraseñas de este proyecto son de demostración; en producción
  se gestionarían con Ansible Vault o Azure Key Vault.

## Licencia

Distribuido bajo la licencia **MIT**. Consulta el fichero [LICENSE](LICENSE).

## Autor

Alberto Aguilera — Caso Práctico 2, Programa Avanzado en DevOps & Cloud (UNIR).