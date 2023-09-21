#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

#############
# VARIABLES #
#############

environment_prefix=$2
assets_directory="../terraform/layers/assets"
scripts_directory="."
build_directory="../terraform/layers/deployments/$1"
dateTime=$(TZ=Australia/Brisbane date +"%FT%H:%M")

###########################
# START OF BASH FUNCTIONS #
###########################

# These functions are being used through out the whole bash script.

if [ "$SHELL" = "/bin/bash" ]; then
    USE_ECHO_E=true
else
    USE_ECHO_E=false
fi

my_echo() {
    if [ "$USE_ECHO_E" = true ]; then
        echo -e "$@"
    else
        echo "$@"
    fi
}

countdown() {
  local seconds="$1"
  while [ "$seconds" -gt 0 ]; do
    my_echo "\033[1;37mCountdown: \033[0;33m$seconds \033[1;37mseconds\033[0K\r"
    sleep 1
    seconds=$((seconds - 1))
  done
  
  my_echo "\033[1;37mCountdown: \033[0;33m0 \033[1;37mseconds\033[0m="
}

delete_deployment_files() {
  rm -rf ".terraform"
  rm -f ".terraform.lock.hcl"
  rm -f "provider.tf"
  rm -f "variables.tf"
  rm -f "resources.tfvars"
}

dynamically_generate_kubernetes_cluster_resource_values() {
  output=$(awk -v RS= -v block="kubernetes_cluster_1" '$0 ~ block' "terraform.tfvars" | \
    awk '/name = {/,/identifier =/ {gsub(/"/, "", $3); print $3}' | \
    sed 's/{//' | sed 's/}//' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' > output.txt)
  
  aks_name_purpose=$(cat output.txt | sed -n '1p')
  aks_name_identifier=$(cat output.txt | sed -n '2p')
  aks_rg_purpose=$(cat output.txt | sed -n '3p')
  aks_rg_identifier=$(cat output.txt | sed -n '4p')
}

dynamically_generate_virtual_machine_resource_values() {
  output=$(awk -v RS= -v block="linux_scale_set_1" '$0 ~ block' "terraform.tfvars" | \
    awk '/name = {/,/identifier =/ {gsub(/"/, "", $3); print $3}' | \
    sed 's/{//' | sed 's/}//' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' > vmss_name_output.txt)

  vmss_name_purpose=$(cat vmss_name_output.txt | sed -n '1p')
  vmss_name_identifier=$(cat vmss_name_output.txt | sed -n '2p')

  rm vmss_name_output.txt

  resource_group_output=$(awk -v RS= -v block="linux_scale_set_1" '$0 ~ block' "terraform.tfvars" | \
      awk '/resource_group = {/,/identifier =/ {gsub(/"/, "", $3); print $3}' | \
      sed 's/{//' | sed 's/}//' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' > resource_group_output.txt)

  vmss_rg_location=$(cat resource_group_output.txt | sed -n '1p')
  vmss_rg_purpose=$(cat resource_group_output.txt | sed -n '2p')
  vmss_rg_identifier=$(cat resource_group_output.txt | sed -n '3p')

  vmss_rg_name="rg-$vmss_rg_purpose-$environment_prefix-aue-$vmss_rg_identifier"

  rm resource_group_output.txt
}


#########################
# END OF BASH FUNCTIONS #
#########################

if [ $# -lt 2 ]; then
  my_echo "\033[1;37m========================================================\033[0m"
  my_echo "\033[1;37m Error: Usage $0 <target_directory> <environment_prefix>. The argument <target_directory> must be either 'virtual_machine' or 'kubernetes_cluster' while the <environment_prefix> must be 3 letters. \033[0m"
  my_echo "\033[1;37m Usage: $0 <target_directory> <environment_prefix> [-plan] [-destroy] \033[0m"
  my_echo "\033[1;37m========================================================\033[0m"
  exit 1
fi

if [ "$1" != "virtual_machine" ] && [ "$1" != "kubernetes_cluster" ]; then
  my_echo "\033[1;37m===================================================================================================\033[0m"
  my_echo "\033[1;37m= Error: Invalid argument. The argument must be either 'virtual_machine' or 'kubernetes_cluster'. =\033[0m"
  my_echo "\033[1;37m===================================================================================================\033[0m"
  exit 1
fi

length=$(echo -n $2 | wc -c)

if [ $length -gt 3 ]; then
  my_echo "\033[1;37m========================================================\033[0m"
  my_echo "\033[1;37m= Error: Environment prefix must be exactly 3 letters. =\033[0m"
  my_echo "\033[1;37m========================================================\033[0m"
  exit 1
fi

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists yq; then
  my_echo "\033[1;37m=============================================================================================\033[0m"
  my_echo "\033[1;37m=      Error: YQ is not installed. Please install it and make sure it's in your PATH.       =\033[0m"
  my_echo "\033[1;37m= If you are using Ubuntu/Linux please run the command: sudo apt-get install yq to install. =\033[0m"
  my_echo "\033[1;37m=            Please review the repository root README.md for install guidance.              =\033[0m"
  my_echo "\033[1;37m=============================================================================================\033[0m"
  exit 1
fi


if ! command_exists az; then
  my_echo "\033[1;37m============================================================================================================================\033[0m"
  my_echo "\033[1;37m=          Error: Azure CLI is not installed. Please install it and make sure it's in your PATH.                           =\033[0m"
  my_echo "\033[1;37m= If you are using Ubuntu/Linux please run the command: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash to install. =\033[0m"
  my_echo "\033[1;37m=                Please review the repository root README.md for install guidance.                                         =\033[0m"
  my_echo "\033[1;37m============================================================================================================================\033[0m"
  exit 1
fi

if ! command_exists terraform; then
  my_echo "\033[1;37m========================================================================================\033[0m"
  my_echo "\033[1;37m= Error: Terraform is not installed. Please install it and make sure it's in your PATH."
  my_echo "\033[1;37m= Please review the repository root README.md for install guidance."
  my_echo "\033[1;37m========================================================================================\033[0m"
  exit 1
fi

if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
  my_echo "\033[1;37m=========================================================================================================================================\033[0m"
  my_echo "\033[1;37m= Error: Environment variables not set. Please ensure ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, and ARM_SUBSCRIPTION_ID are set. =\033[0m"
  my_echo "\033[1;37m=========================================================================================================================================\033[0m"
  exit 1
fi

az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"

if [ $? -ne 0 ]; then
  my_echo "\033[1;37m===============================================================================\033[0m"
  my_echo "\033[1;37m= Error: Azure login failed. Please check your service principal credentials. =\033[0m"
  my_echo "\033[1;37m===============================================================================\033[0m"
  exit 1
fi

az account set --subscription "$ARM_SUBSCRIPTION_ID"

if [ $? -ne 0 ]; then
  my_echo "\033[1;37m============================================================================\033[0m"
  my_echo "\033[1;37m= Error: Azure subscription set failed. Please check your subscription ID. =\033[0m"
  my_echo "\033[1;37m============================================================================\033[0m"
  exit 1
fi

if [ ! -d "$assets_directory" ]; then
  my_echo "\033[1;37m===========================================\033[0m"
  my_echo "\033[1;37m= Error: Source directory does not exist. =\033[0m"
  my_echo "\033[1;37m===========================================\033[0m"
  exit 1
fi

if [ ! -d "$build_directory" ]; then
  my_echo "\033[1;37m========================================================================================\033[0m"
  my_echo "\033[1;37m= Error: Build directory does not exist. Please check the name of the build directory. =\033[0m"
  my_echo "\033[1;37m========================================================================================\033[0m"
  exit 1
fi

cp -ru $assets_directory/* $build_directory/

if [ $? -eq 0 ]; then
  my_echo
  my_echo "\033[1;37m================================================\033[0m"
  my_echo "\033[1;37mFiles copied successfully from assets directory.\033[0m"
  my_echo "\033[1;37m================================================\033[0m"
  my_echo
else
  my_echo "\033[1;37m=======================================================\033[0m"
  my_echo "\033[1;37m= No new files copied. Existing files are up to date. =\033[0m"
  my_echo "\033[1;37m=======================================================\033[0m"
fi

storage_account_name=$(yq eval '.Terraform.Backend.storage_account_name' $scripts_directory/config.yml)
resource_group_name=$(yq eval '.Terraform.Backend.resource_group_name' $scripts_directory/config.yml)
container_name=$(yq eval '.Terraform.Backend.container_name' $scripts_directory/config.yml)
managed_by=$(yq eval '.Terraform.Modules.Variables.Tags.managedBy' $scripts_directory/config.yml)


cd $build_directory

deploy_terraform_apply=true
destroy_terraform=false

for arg in "$3"; do
  case $arg in
    -plan)
      deploy_terraform_apply=false
      ;;
    *)
      ;;
  esac
done

access_key=$(az storage account keys list --resource-group $resource_group_name --account-name $storage_account_name --query '[0].value' --output tsv)

terraform init \
  -backend-config="resource_group_name=$resource_group_name" \
  -backend-config="storage_account_name=$storage_account_name" \
  -backend-config="container_name=$container_name" \
  -backend-config="access_key=$access_key" \
  -backend-config="client_secret=$ARM_CLIENT_SECRET" \
  -backend-config="subscription_id=$ARM_SUBSCRIPTION_ID" \
  -backend-config="tenant_id=$ARM_TENANT_ID" \
  -backend-config="key=$1/terraform.tfstate" \
  -upgrade

if [ $? -ne 0 ]; then
  my_echo "\033[1;37m======================================================\033[0m"
  my_echo "\033[1;37m= Error: Terraform init failed. Aborting deployment. =\033[0m"
  my_echo "\033[1;37m======================================================\033[0m"
  exit 1
fi

terraform validate

deploy_suffix=""
if [ $# -ge 3 ] ||  [ $# -ge 4 ] && { [ "$3" = "-destroy" ] || [ "$4" = "-destroy" ]; }; then
  destroy_terraform=true
  if [ "$destroy_terraform" = true ]; then
  deploy_suffix="-destroy"
  fi
fi

ssh_key_file="$HOME/.ssh/azure"
ssh_pub_key_file="$HOME/.ssh/azure.pub"

if [ ! -f "$ssh_key_file" ] && [ ! -f "$ssh_pub_key_file" ]; then

  ssh-keygen -m PEM -t rsa -b 2048 -f "$ssh_key_file" -N ""
fi

ssh_key=$(cat "$ssh_pub_key_file")

terraform plan $deploy_suffix \
  -var="environment=$environment_prefix" \
  -var="managedBy=$managed_by" \
  -var="dateCreated=$dateTime" \
  -var="ssh_public_key=$ssh_key" \
  -var-file=terraform.tfvars \
  -var-file=resources.tfvars \
  -out=$1-$environment_prefix-plan.out

if [ $? -ne 0 ]; then
  my_echo "\033[1;37m======================================================\033[0m"
  my_echo "\033[1;37m= Error: Terraform plan failed. Aborting deployment. =\033[0m"
  my_echo "\033[1;37m======================================================\033[0m"
  exit 1
fi

if [ "$deploy_terraform_apply" = true ]; then
  terraform apply $deploy_suffix \
    -var="environment=$environment_prefix" \
    -var="managedBy=$managed_by" \
    -var="dateCreated=$dateTime" \
    -var="ssh_public_key=$ssh_key" \
    -var-file=terraform.tfvars \
    -var-file=resources.tfvars \
    -auto-approve

  if [ $? -ne 0 ]; then
    my_echo "\033[1;37m===========================================================\033[0m"
    my_echo "\033[1;37m= Error: Terraform apply failed. Deployment unsuccessful. =\033[0m"
    my_echo "\033[1;37m===========================================================\033[0m"
    exit 1
  fi
else
  my_echo "\033[1;37m============================================================\033[0m"
  my_echo "\033[1;37m= Terraform apply is skipped as -plan option was provided. =\033[0m"
  my_echo "\033[1;37m============================================================\033[0m"
fi

rm -f "$1-$environment_prefix-plan.out"
delete_deployment_files

if [ "$deploy_terraform_apply" = true ] && [ "$destroy_terraform" = false ] && [ "$1" = "virtual_machine" ]; then

  if ! command_exists ansible; then
    my_echo "\033[1;37m=======================================================================================\033[0m"
    my_echo "\033[1;37m= Error: Ansible is not installed. Please install it and make sure it's in your PATH. =\033[0m"
    my_echo "\033[1;37m=       Please review the repository root README.md for install guidance.             =\033[0m"
    my_echo "\033[1;37m=======================================================================================\033[0m"
    exit 1
  fi

  echo

  dynamically_generate_virtual_machine_resource_values

  vmssList=$(az vmss list --resource-group $vmss_rg_name --query "[].{Name:name}" --output tsv)

  my_echo "\033[1;37m============================================\033[0m"
  my_echo "\033[1;37m= Searching for vmsss name, please wait... =\033[0m"
  my_echo "\033[1;37m============================================\033[0m"
  my_echo "\033[1;37m               \033[0;33m$vmssList                   \033[0m"
  for vmssName in $vmssList; do
    vmssInstances=$(az vmss list-instances --resource-group $vmss_rg_name --name $vmssName --query "[].{Name:name}" --output tsv)
    for instanceInfo in $vmssInstances; do
      instanceName="${instanceInfo%_*}"
      instanceId="${instanceInfo##*_}"
      publicIpAddress=$(az vmss list-instance-public-ips --resource-group $vmss_rg_name --name $vmssName --query "[?contains(id, '/$instanceId/')].ipAddress" --output tsv)
      
      # Added this count down to ensure the Nginx server has been updated and applied to the VMSS to ensure the webserver is running.
      echo
      my_echo "\033[1;37m============================================================\033[0m"
      my_echo "\033[1;37m= Please wait for VMSS to finish updating and go online... =\033[0m"
      my_echo "\033[1;37m============================================================\033[0m"

      countdown 15
      
      htmlContent=$(curl -k https://$publicIpAddress | grep -o '<title>.*</title>' | sed -e 's/<title>//;s/<\/title>//;s/<!.*>//g' | awk 'NF')
      if echo "$htmlContent" | grep -q "Hello, World!"; then
          my_echo "\033[1;37m==================================================\033[0m"
          my_echo "\033[1;37m| Nginx Server is Live at: \033[0;33mhttps://$publicIpAddress\033[0m |"
          my_echo "\033[1;37m==================================================\033[0m"

          my_echo "\033[1;37m=========================================================\033[0m"
          my_echo "\033[1;37m         SSH Server Information Login with\033[0m"
          my_echo "\033[0;33m ssh -i $HOME/.ssh/azure adminuser@$publicIpAddress\033[0m"
          my_echo "\033[1;37m=========================================================\033[0m"
      else
          my_echo "\033[1;37m=======================================================================================================================\033[0m"
          my_echo "\033[1;37m The \033[0;33m$vmssName\033[0m with the instance name of \033[0;33m$instanceName\033[0m with an instance id of \033[0;33m$instanceId\033[0m. \033[1;37mIs not hosting an Nginx Server.\033[0m"
          my_echo "\033[1;37m=======================================================================================================================\033[0m"

          my_echo "\033[1;37m========================================================\033[0m"
          my_echo "\033[1;37m         SSH Server Information Login with\033[0m"
          my_echo "\033[0;33m ssh -i $HOME/.ssh/azure adminuser@$publicIpAddress\033[0m"
          my_echo "\033[1;37m========================================================\033[0m"
      fi
    done
  done
  # Delete the copied asset files, and auto generated files from your local host since you will be pulling state from storage account.

  ######################################
  # Ansible Section of the Bash Script #
  ######################################

  read -p "Do you want to update nginx webpage with an Ansible playbook (y/n)? " answer

  # Check if the user's response is not one of the accepted values
  if [ "$answer" != "yes" ] && [ "$answer" != "y" ] && [ "$answer" != "ye" ] && [ "$answer" != "ya" ]; then
    my_echo "\033[1;37m==============================\033[0m"
    my_echo "\033[1;37m= Script has been completed. =\033[0m"
    my_echo "\033[1;37m==============================\033[0m"
    exit 1
  fi

  my_echo "\033[1;37m=============================================================\033[0m"
  my_echo "\033[1;37m        Preparing Hosts File for: \033[0;33m$publicIpAddress\033[0m"
  my_echo "\033[1;37m=============================================================\033[0m"

  hosts_file="../../../../ansible/inventory/hosts.ini"
  sed -i "/^\[azure_vm\]/a $publicIpAddress ansible_user=adminuser ansible_ssh_private_key_file=/$HOME/.ssh/azure" $hosts_file
  # Check if [azure_vm] exists in the file
  cd ../../../../ansible/playbooks
  ansible-playbook -i ../inventory/hosts.ini update_nginx.yml
  my_echo "\033[1;37m==============================\033[0m"
  my_echo "\033[1;37m= Script has been completed. =\033[0m"
  my_echo "\033[1;37m==============================\033[0m"
  exit 1
fi

#########################################
# Kubernetes Section of the Bash Script #
#########################################

if [ "$deploy_terraform_apply" = true ] && [ "$destroy_terraform" = false ] && [ "$1" = "kubernetes_cluster" ]; then

  my_echo "\033[1;37m====================================================\033[0m"
  my_echo "\033[1;37m= Preparing to Deploy the Kubernetes Manifest File =\033[0m"
  my_echo "\033[1;37m====================================================\033[0m"

  dynamically_generate_kubernetes_cluster_resource_values

  if [ -z "$aks_name_purpose" ] || [ -z "$aks_name_identifier" ] || [ -z "$aks_rg_purpose" ] || [ -z "$aks_rg_identifier" ]; then
    my_echo "\033[1;37m=====================================================================================================\033[0m"
    my_echo "\033[1;37m= Naming convention variables have not been set in the previous task please review the bash script. =\033[0m"
    my_echo "\033[1;37m=====================================================================================================\033[0m"
    exit 1
  fi

  if ! command -v kubectl &> /dev/null; then
      my_echo "\033[1;37m===========================================================\033[0m"
      my_echo "\033[1;37m= Error: 'kubectl' command not found. Installing kubectl. =\033[0m"
      my_echo "\033[1;37m===========================================================\033[0m"
  fi


  az aks get-credentials --resource-group rg-$aks_rg_purpose-$environment_prefix-aue-$aks_rg_identifier --name akc-$aks_name_purpose-$environment_prefix-aue-$aks_name_identifier

  if ! kubectl get nodes -o wide; then
      my_echo "\033[1;37m===========================================\033[0m"
      my_echo "\033[1;37m= Error: Failed to get the list of nodes. =\033[0m"
      my_echo "\033[1;37m===========================================\033[0m"
      exit 1
  fi

  cd ../../../../kubernetes

  if ! kubectl apply -f nginx-webserver.yml; then
      my_echo "\033[1;37m==================================================\033[0m"
      my_echo "\033[1;37m= Error: Failed to apply the YAML configuration. =\033[0m"
      my_echo "\033[1;37m==================================================\033[0m"
      exit 1
  fi

  my_echo "\033[1;37m================================================================\033[0m"
  my_echo "\033[1;37m= Please wait for manifest service public ip to get allocated. =\033[0m"
  my_echo "\033[1;37m================================================================\033[0m"

  countdown 25

  pod_ip=$(kubectl get svc nginx-hello-world -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  my_echo "\033[1;37m======================================================================"
  my_echo "\033[1;37m= Kubernetes Pod Nginx Server is Live at: \033[0;33mhttp://$pod_ip\033[0m ="
  my_echo "\033[1;37m======================================================================"

  cd ../terraform/layers/deployments/$1

  delete_deployment_files
fi