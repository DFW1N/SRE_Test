#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

# Check if at least the first two arguments are provided
if [ $# -lt 2 ]; then
  echo "--------------------------------------------------"
  echo "Error: Usage $0 <target_directory> <environment_prefix>. The argument <target_directory> must be either 'virtual_machine' or 'kubernetes_cluster' while the <environment_prefix> must be 3 letters."
  echo
  echo "Usage: $0 <target_directory> <environment_prefix> [-plan]"
  exit 1
fi

# Check if the provided argument is valid ('virtual_machine' or 'kubernetes_cluster')
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

# Convert input value to a variable for environment prefix.
environment_prefix=$2

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Azure CLI is installed
if ! command_exists az; then
  echo "--------------------------------------------------"
  echo "Error: Azure CLI is not installed. Please install it and make sure it's in your PATH."
  exit 1
fi

# Check if YQ is installed
if ! command_exists yq; then
  echo "--------------------------------------------------"
  echo "Error: YQ is not installed. Please install it and make sure it's in your PATH."
  echo "If you are using Ubuntu/Linux please run the command: sudo apt-get install yq to install."
  exit 1
fi

# Check if Terraform is installed
if ! command_exists terraform; then
  echo "--------------------------------------------------"
  echo "Error: Terraform is not installed. Please install it and make sure it's in your PATH."
  exit 1
fi

# Check if the required environment variables are set
if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
  echo "--------------------------------------------------"
  echo "Error: Environment variables not set. Please ensure ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, and ARM_SUBSCRIPTION_ID are set."
  exit 1
fi

# Authenticate to Azure using environment variables
az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"

# Check the exit status of the az login command
if [ $? -ne 0 ]; then
  echo "Error: Azure login failed. Please check your service principal credentials."
  exit 1
fi

# Set the Azure subscription
az account set --subscription "$ARM_SUBSCRIPTION_ID"

# Check the exit status of the az account set command
if [ $? -ne 0 ]; then
  echo "--------------------------------------------------"
  echo "Error: Azure subscription set failed. Please check your subscription ID."
  exit 1
fi

# Terraform assets directory.
assets_directory="../terraform/layers/assets"
# Script directory.
scripts_directory="."
# Terraform build directory where the CLI will be executed from.
build_directory="../terraform/layers/deployments/$1"

# Read values from config.yml using yq
storage_account_name=$(yq eval '.Terraform.Backend.storage_account_name' $scripts_directory/config.yml)
resource_group_name=$(yq eval '.Terraform.Backend.resource_group_name' $scripts_directory/config.yml)
container_name=$(yq eval '.Terraform.Backend.container_name' $scripts_directory/config.yml)
# Read values from config.yml using yq for common terraform module variables
managed_by=$(yq eval '.Terraform.Modules.Variables.Tags.managedBy' $scripts_directory/config.yml)

# Set the Date Created for the Infrastructure as a Default Tag
dateTime=$(TZ=Australia/Brisbane date +"%FT%H:%M")

# Added Error Handling

if [ ! -d "$assets_directory" ]; then
  echo "--------------------------------------------------"
  echo "Error: Source directory does not exist."
  exit 1
fi

if [ ! -d "$build_directory" ]; then
  echo "--------------------------------------------------"
  echo "Error: Build directory does not exist. Please check the name of the build directory."
  exit 1
fi

# Perform the copy operation
cp -ru $assets_directory/* $build_directory/

# Check the exit status of the cp command
if [ $? -eq 0 ]; then
  echo "--------------------------------------------------"
  echo "Files copied successfully."
  echo
else
  echo "--------------------------------------------------"
  echo "No new files copied. Existing files are up to date."
fi

# Change to the target build directory
cd $build_directory

# Initialize a flag to determine whether to execute terraform apply
deploy_terraform_apply=true

# Iterate over command-line arguments
for arg in "$3"; do
  case $arg in
    -plan)
      deploy_terraform_apply=false
      ;;
    *)
      ;;
  esac
done

# Retrieve the access key (key1)
access_key=$(az storage account keys list --resource-group $resource_group_name --account-name $storage_account_name --query '[0].value' --output tsv)

# Run Terraform commands
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

# Check the exit status of terraform init
if [ $? -ne 0 ]; then
  echo "--------------------------------------------------"
  echo "Error: Terraform init failed. Aborting deployment."
  exit 1
fi

# Validate the terraform code
terraform validate

# Run Terraform Plan

terraform plan \
  -var="environment=$environment_prefix" \
  -var="managedBy=$managed_by" \
  -var="dateCreated=$dateTime" \
  -var-file=terraform.tfvars \
  -var-file=resources.tfvars \
  -out=$1-$environment_prefix-plan.out

# Check the exit status of terraform plan
if [ $? -ne 0 ]; then
  echo "--------------------------------------------------"
  echo "Error: Terraform plan failed. Aborting deployment."
  exit 1
fi

# Run Terraform Apply
if [ "$deploy_terraform_apply" = true ]; then
  terraform apply \
    -var="environment=$environment_prefix" \
    -var="managedBy=$managed_by" \
    -var="dateCreated=$dateTime" \
    -var-file=terraform.tfvars \
    -var-file=resources.tfvars \
    -auto-approve

  # Check the exit status of terraform apply
  if [ $? -ne 0 ]; then
  echo "---------------------------------------------------------"
    echo "Error: Terraform apply failed. Deployment unsuccessful."
    exit 1
  fi
else
  echo "--------------------------------------------------------"
  echo "Terraform apply is skipped as -plan option was provided."
fi

if [ "$deploy_terraform_apply" = true ] && [ "$1" = "virtual_machine" ]; then
  echo
  # Notify the user that the script is iterating through resource groups
  echo "=================================================================="
  echo "= \033[1;37mIterating through resource groups to find VMSS. Please wait... \033[0m="
  echo "=================================================================="

  resourceGroups=$(az group list --query "[].name" --output tsv)
  resourceGroupsContainingVMSS=""

  # Iterate over each resource group
  for rg in $resourceGroups; do
    # Use the Azure CLI to check if there are VMSS resources in the current resource group
    vmssList=$(az vmss list --resource-group $rg --query "length(@)")
      
    if [ "$vmssList" -gt 0 ]; then
      resourceGroupsContainingVMSS="$resourceGroupsContainingVMSS $rg"
    fi
  done

  # Check if any resource groups contain VMSS
  if [ -n "$resourceGroupsContainingVMSS" ]; then
    echo
    echo "======== \033[1;37mResource Groups Containing VMSS\033[0m= ========="
    for rg in $resourceGroupsContainingVMSS; do
      echo "================================================"
      echo "           \033[0;33m$rg\033[0m"
      echo "================================================"
      # List VMSS resources in the current resource group
      vmssList=$(az vmss list --resource-group $rg --query "[].{Name:name}" --output tsv)
      # Iterate over VMSS instances and retrieve public IPs and instance IDs
      for vmssName in $vmssList; do
        vmssInstances=$(az vmss list-instances --resource-group $rg --name $vmssName --query "[].{Name:name}" --output tsv)
        # Iterate over VMSS instances and retrieve public IPs and instance IDs
        for instanceInfo in $vmssInstances; do
          instanceName="${instanceInfo%_*}"
          instanceId="${instanceInfo##*_}"
          # Query the public IP address associated with the VMSS instance using 'jq'
          publicIpAddress=$(az vmss list-instance-public-ips --resource-group $rg --name $vmssName --query "[?contains(id, '/$instanceId/')].ipAddress" --output tsv)
          # Use 'curl' to fetch the HTML content and 'grep' to check if it contains "Hello, World!"
          htmlContent=$(curl -s $publicIpAddress)
          if echo "$htmlContent" | grep -q "Hello, World!"; then
              echo "================================================"
              echo "Nginx Server is Live at: \033[0;33mhttp://$publicIpAddress\033[0m"
              echo "================================================"
          else
              echo "========================================================================================================"
              echo "The \033[0;33m$vmssName\033[0m with the instance name of \033[0;33m$instanceName\033[0m with an instance id of \033[0;33m$instanceId\033[0m. Is not hosting an Nginx Server."
              echo "========================================================================================================"
          fi
        done
      done
    done
  else
    echo "--------------------------------------------------------------------"
    echo "No resource groups containing VMSS found in your Azure subscription."
  fi

  # Notify the user that the process is complete
  echo "----------------------------------------------"
  echo "VMSS search and public IP retrieval completed."
  echo "----------------------------------------------"
fi