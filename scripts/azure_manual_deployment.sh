#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

if [ $# -lt 2 ]; then
  echo "--------------------------------------------------"
  echo "Error: Usage $0 <target_directory> <environment_prefix>. The argument <target_directory> must be either 'virtual_machine' or 'kubernetes_cluster' while the <environment_prefix> must be 3 letters."
  echo
  echo "Usage: $0 <target_directory> <environment_prefix> [-plan] [-destroy]"
  exit 1
fi

if [ "$1" != "virtual_machine" ] && [ "$1" != "kubernetes_cluster" ]; then
  echo "--------------------------------------------------"
  echo "Error: Invalid argument. The argument must be either 'virtual_machine' or 'kubernetes_cluster'."
  exit 1
fi

length=$(echo -n $2 | wc -c)

if [ $length -gt 3 ]; then
  echo "--------------------------------------------------"
  echo "Error: Environment prefix must be exactly 3 letters."
  exit 1
fi

environment_prefix=$2

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists az; then
  echo "--------------------------------------------------"
  echo "Error: Azure CLI is not installed. Please install it and make sure it's in your PATH."
  echo "If you are using Ubuntu/Linux please run the command: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash to install."
  exit 1
fi

if ! command_exists yq; then
  echo "--------------------------------------------------"
  echo "Error: YQ is not installed. Please install it and make sure it's in your PATH."
  echo "If you are using Ubuntu/Linux please run the command: sudo apt-get install yq to install."
  exit 1
fi

if ! command_exists terraform; then
  echo -e "\033[1;37m===========================================================================\033[0m"
  echo "Error: Terraform is not installed. Please install it and make sure it's in your PATH."
  exit 1
fi

if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
  echo -e "\033[1;37m===========================================================================================================================\033[0m"
  echo "Error: Environment variables not set. Please ensure ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, and ARM_SUBSCRIPTION_ID are set."
  exit 1
fi

az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"

if [ $? -ne 0 ]; then
  echo "Error: Azure login failed. Please check your service principal credentials."
  exit 1
fi

az account set --subscription "$ARM_SUBSCRIPTION_ID"

if [ $? -ne 0 ]; then
  echo -e "\033[1;37m==============================================================\033[0m"
  echo "Error: Azure subscription set failed. Please check your subscription ID."
  exit 1
fi

# Terraform assets directory.
assets_directory="../terraform/layers/assets"
# Script directory.
scripts_directory="."
# Terraform build directory where the CLI will be executed from.
build_directory="../terraform/layers/deployments/$1"

#################################
# Config.yml Declared Variables #
#################################

storage_account_name=$(yq eval '.Terraform.Backend.storage_account_name' $scripts_directory/config.yml)
resource_group_name=$(yq eval '.Terraform.Backend.resource_group_name' $scripts_directory/config.yml)
container_name=$(yq eval '.Terraform.Backend.container_name' $scripts_directory/config.yml)

####################
# Module Variables #
####################

managed_by=$(yq eval '.Terraform.Modules.Variables.Tags.managedBy' $scripts_directory/config.yml)

dateTime=$(TZ=Australia/Brisbane date +"%FT%H:%M")

if [ ! -d "$assets_directory" ]; then
  echo -e "\033[1;37m=============================\033[0m"
  echo "Error: Source directory does not exist."
  echo -e "\033[1;37m=============================\033[0m"
  exit 1
fi

if [ ! -d "$build_directory" ]; then
  echo -e "\033[1;37m==========================================================================\033[0m"
  echo "Error: Build directory does not exist. Please check the name of the build directory."
  echo -e "\033[1;37m==========================================================================\033[0m"
  exit 1
fi

cp -ru $assets_directory/* $build_directory/

if [ $? -eq 0 ]; then
  echo
  echo -e "\033[1;37m================================================\033[0m"
  echo -e "\033[1;37mFiles copied successfully from assets directory.\033[0m"
  echo -e "\033[1;37m================================================\033[0m"
  echo
else
  echo -e "\033[1;37m========================================\033[0m"
  echo "No new files copied. Existing files are up to date."
  echo -e "\033[1;37m========================================\033[0m"
fi

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
  echo "--------------------------------------------------"
  echo "Error: Terraform init failed. Aborting deployment."
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
  echo "--------------------------------------------------"
  echo "Error: Terraform plan failed. Aborting deployment."
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
  echo "---------------------------------------------------------"
    echo "Error: Terraform apply failed. Deployment unsuccessful."
    exit 1
  fi
else
  echo "--------------------------------------------------------"
  echo "Terraform apply is skipped as -plan option was provided."
fi

if [ "$deploy_terraform_apply" = true ] && [ "$destroy_terraform" = false ] && [ "$1" = "virtual_machine" ]; then

  echo
  echo "=================================================================="
  echo -e "= \033[1;37mIterating through resource groups to find VMSS. Please wait... \033[0m="
  echo "=================================================================="

  resourceGroups=$(az group list --query "[].name" --output tsv)
  resourceGroupsContainingVMSS=""

  for rg in $resourceGroups; do
    vmssList=$(az vmss list --resource-group $rg --query "length(@)")
      
    if [ "$vmssList" -gt 0 ]; then
      resourceGroupsContainingVMSS="$resourceGroupsContainingVMSS $rg"
    fi
  done

  if [ -n "$resourceGroupsContainingVMSS" ]; then
    echo
    echo -e "======= \033[1;37mResource Groups Containing VMSS\033[0m========="
    for rg in $resourceGroupsContainingVMSS; do
      echo "================================================"
      echo -e "              \033[0;33m$rg\033[0m"
      echo "================================================"

      vmssList=$(az vmss list --resource-group $rg --query "[].{Name:name}" --output tsv)
      for vmssName in $vmssList; do
        vmssInstances=$(az vmss list-instances --resource-group $rg --name $vmssName --query "[].{Name:name}" --output tsv)
        for instanceInfo in $vmssInstances; do
          instanceName="${instanceInfo%_*}"
          instanceId="${instanceInfo##*_}"
          publicIpAddress=$(az vmss list-instance-public-ips --resource-group $rg --name $vmssName --query "[?contains(id, '/$instanceId/')].ipAddress" --output tsv)
          
          # Added this count down to ensure the Nginx server has been updated and applied to the VMSS to ensure the webserver is running.
          echo
          echo "============================================================"
          echo -e "= \033[1;37mPlease wait for VMSS to finish updating and go online... \033[0m="
          echo "============================================================"

          countdown() {
            local seconds="$1"
            while [ "$seconds" -gt 0 ]; do
              echo -e "\033[1;37mCountdown: \033[0;33m$seconds \033[1;37mseconds\033[0K\r"
              sleep 1
              seconds=$((seconds - 1))
            done
            
            echo -e "\033[1;37mCountdown: \033[0;33m0 \033[1;37mseconds\033[0m="
          }

          countdown 30
          
          htmlContent=$(curl -s $publicIpAddress)
          if echo "$htmlContent" | grep -q "Hello, World!"; then
              echo "================================================"
              echo -e "  \033[1;37mNginx Server is Live at: \033[0;33mhttp://$publicIpAddress\033[0m"
              echo "================================================"
          else
              echo "========================================================================================================"
              echo -e "The \033[0;33m$vmssName\033[0m with the instance name of \033[0;33m$instanceName\033[0m with an instance id of \033[0;33m$instanceId\033[0m. Is not hosting an Nginx Server."
              echo "========================================================================================================"
          fi
        done
      done
    done
  else
    echo "--------------------------------------------------------------------"
    echo "No resource groups containing VMSS found in your Azure subscription."
  fi

  echo "================================================"
  echo -e "  \033[1;37m SSH Server Information Login with\033[0m="
  echo -e "  \033[0;33m ssh -i $HOME/.ssh/azure adminuser@$publicIpAddress\033[0m"
  echo "================================================"

  # Delete the copied asset files, and auto generated files from your local host since you will be pulling state from storage account.

  rm -rf ".terraform"
  rm -f ".terraform.lock.hcl"
  rm -f "provider.tf"
  rm -f "variables.tf"
  rm -f "resources.tfvars"
  rm -f "$1-$environment_prefix-plan.out"

  ######################################
  # Ansible Section of the Bash Script #
  ######################################

  read -p "Do you want to update nginx webpage with an Ansible playbook (y/n)? " answer

  # Check if the user's response is not one of the accepted values
  if [ "$answer" != "yes" ] && [ "$answer" != "y" ] && [ "$answer" != "ye" ] && [ "$answer" != "ya" ]; then
    echo "Script has been completed."
    exit 1
  fi

  echo "================================================"
  echo -e "  \033[1;37mPreparing Hosts File for: \033[0;33m$publicIpAddress\033[0m"
  echo "================================================"

  hosts_file="../../../../ansible/inventory/hosts.ini"
  sed -i "/^\[azure_vm\]/a $publicIpAddress ansible_user=adminuser ansible_ssh_private_key_file=/$HOME/.ssh/azure" $hosts_file
  # Check if [azure_vm] exists in the file
  cd ../../../../ansible/playbooks
  ansible-playbook -i ../inventory/hosts.ini update_nginx.yml

fi

#########################################
# Kubernetes Section of the Bash Script #
#########################################

if [ "$deploy_terraform_apply" = true ] && [ "$destroy_terraform" = false ] && [ "$1" = "kubernetes_cluster" ]; then

  echo "==============================================================="
  echo -e "  \033[1;37mPreparing to Deploy the Kubernetes Manifest File\033[0m"
  echo "==============================================================="

  output=$(awk -v RS= -v block="kubernetes_cluster_1" '$0 ~ block' "terraform.tfvars" | \
    awk '/name = {/,/identifier =/ {gsub(/"/, "", $3); print $3}' | \
    sed 's/{//' | sed 's/}//' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' > output.txt)
  
  aks_name_purpose=$(cat output.txt | sed -n '1p')
  aks_name_identifier=$(cat output.txt | sed -n '2p')
  aks_rg_purpose=$(cat output.txt | sed -n '3p')
  aks_rg_identifier=$(cat output.txt | sed -n '4p')

  if [ -z "$aks_name_purpose" ] || [ -z "$aks_name_identifier" ] || [ -z "$aks_rg_purpose" ] || [ -z "$aks_rg_identifier" ]; then
    echo -e "\033[1;37m===========================================================================================================================\033[0m"
    echo "Naming convention vairables have not been set in the previous task please review the bash script."
    exit 1
  fi

  rm output.txt

  az aks get-credentials --resource-group rg-$aks_rg_purpose-$environment_prefix-aue-$aks_rg_identifier --name akc-$aks_name_purpose-$environment_prefix-aue-$aks_name_identifier

  if ! kubectl get nodes -o wide; then
      echo "Error: Failed to get the list of nodes."
      exit 1
  fi


  cd ../../../../kubernetes

  if ! kubectl apply -f nginx-webserver.yml; then
      echo "Error: Failed to apply the YAML configuration."
      exit 1
  fi

  echo "==========================================================================="
  echo -e "  \033[1;37mPlease wait for manifest service public ip to get allocated.\033[0m"
  echo "==========================================================================="

  countdown() {
    local seconds="$1"
    while [ "$seconds" -gt 0 ]; do
      echo -e "\033[1;37mCountdown: \033[0;33m$seconds \033[1;37mseconds\033[0K\r"
      sleep 1
      seconds=$((seconds - 1))
    done
    
    echo -e "\033[1;37mCountdown: \033[0;33m0 \033[1;37mseconds\033[0m="
  }

  countdown 10

  pod_ip=$(kubectl get svc nginx-hello-world -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo "====================================================================="
  echo -e "  \033[1;37mKubernetes Pod Nginx Server is Live at: \033[0;33mhttp://$pod_ip\033[0m"
  echo "====================================================================="

  cd ../terraform/layers/deployments/$1

  rm -rf ".terraform"
  rm -f ".terraform.lock.hcl"
  rm -f "provider.tf"
  rm -f "variables.tf"
  rm -f "resources.tfvars"
  rm -f "$1-$environment_prefix-plan.out"
fi