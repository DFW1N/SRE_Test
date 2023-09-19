#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

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
