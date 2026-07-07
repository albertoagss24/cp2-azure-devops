#!/bin/bash

# deploy.sh - Ejecuta el playbook pasando las credenciales del ACR obtenidas de los outputs de Terraform (así NO se guardan en Git).

set -euo pipefail

# Leer las credenciales del ACR desde los outputs de Terraform
# El 'cd ../terraform' va dentro de un subshell para no cambiar el directorio del script principal
ACR_SERVER=$(cd ../terraform && terraform output -raw acr_login_server)
ACR_USER=$(cd ../terraform && terraform output -raw acr_admin_username)
ACR_PASS=$(cd ../terraform && terraform output -raw acr_admin_password)

# Efecutar el playbook con esas credenciales como variables extra
ansible-playbook playbook.yml \
    -e "acr_login_server=${ACR_SERVER}" \
    -e "acr_username=${ACR_USER}" \
    -e "acr_password=${ACR_PASS}"