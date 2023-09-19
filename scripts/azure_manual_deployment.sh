#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

# Check if an argument (target directory name) is provided
if [ $# -ne 1 ]; then
  echo "Error: Usage $0 <target_directory>. The argument must be either 'virtual_machine' or 'kubernetes_cluster'."
  exit 1
fi

# Check if the provided argument is valid ('virtual_machine' or 'kubernetes_cluster')
if [ "$1" != "virtual_machine" ] && [ "$1" != "kubernetes_cluster" ]; then
  echo "Error: Invalid argument. The argument must be either 'virtual_machine' or 'kubernetes_cluster'."
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Azure CLI is installed
if ! command_exists az; then
  echo "Error: Azure CLI is not installed. Please install it and make sure it's in your PATH."
  exit 1
fi

# Check if Terraform is installed
if ! command_exists terraform; then
  echo "Error: Terraform is not installed. Please install it and make sure it's in your PATH."
  exit 1
fi

# Check if the required environment variables are set
if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
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
  echo "Error: Azure subscription set failed. Please check your subscription ID."
  exit 1
fi

# Terraform assets directory.
assets_directory="../terraform/layers/assets"

# Terraform build directory where the CLI will be executed from.
build_directory="../terraform/layers/deployments/$1"

# Add Error Handling

if [ ! -d "$assets_directory" ]; then
  echo "Error: Source directory does not exist."
  exit 1
fi

if [ ! -d "$build_directory" ]; then
  echo "Error: Build directory does not exist. Please check the name of the build directory."
fi

# Perform the copy operation
cp -r . "$assets_directory"/* "$build_directory/ --exclude="README.md"

# Check the exit status of the cp command
if [ $? -ne 0 ]; then
  echo "Error: Copy operation failed."
  exit 1
fi

# Change to the target build directory
cd $build_directory

# Read values from config.yml using yq
storage_account_name=$(yq eval '.Terraform.Backend.storage_account_name' config.yml)
resource_group_name=$(yq eval '.Terraform.Backend.resource_group_name' config.yml)
container_name=$(yq eval '.Terraform.Backend.container_name' config.yml)

# Run Terraform commands
terraform init \
-backend-config="resource_group_name=$resource_group_name" \
-backend-config="storage_account_name=$storage_account_name" \
-backend-config="container_name=$container_name" \
-backend-config="client_secret=$ARM_CLIENT_ID" \
-backend-config="subscription_id=$ARM_SUBSCRIPTION_ID" \
-backend-config="tenant_id=$ARM_TENANT_ID" \
-backend-config="key=terraform.tfstate" \
-upgrade

# Validate the terraform code
terraform validate
