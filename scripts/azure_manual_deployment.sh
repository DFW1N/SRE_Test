#!/bin/bash

#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#############
# VARIABLES #
#############

environment_prefix=$2
assets_directory="../terraform/layers/assets"
scripts_directory="."
build_directory="../terraform/layers/deployments/$1"
dateTime=$(TZ=Australia/Brisbane date +"%FT%H:%M")
ansible_user="adminuser"
USE_ECHO_E=true

declare -A region_prefixes=(
  [australiaeast]="aue"
  [australiacentral]="auc"
  [australiacentral2]="ac2"
  [australiasoutheast]="ase"
  [centralus]="cus"
  [eastus]="eus"
  [eastus2]="eu2"
  [westus]="wus"
  [westus2]="wu2"
  [westus3]="wu3"
  [southcentralus]="scu"
  [westcentralus]="wcu"
  [northcentralus]="ncu"
  [southeastasia]="sea"
  [eastasia]="eaa"
  [westeurope]="weu"
  [northeurope]="noe"
  [swedencentral]="swc"
  [uksouth]="uks"
  [ukwest]="ukw"
  [southafricanorth]="san"
  [southafricawest]="saw"
  [centralindia]="cei"
  [japaneast]="jae"
  [japanwest]="jaw"
  [koreacentral]="koc"
  [koreasouth]="kos"
  [canadacentral]="cac"
  [francecentral]="frc"
  [francesouth]="frs"
  [germanywestcentral]="gwc"
  [germanynorth]="gen"
  [norwayeast]="nwe"
  [norwaywest]="now"
  [switzerlandnorth]="sln"
  [switzerlandwest]="sww"
  [brazilsouth]="brs"
  [brazilsoutheast]="bse"
  [jioindiawest]="jiw"
  [jioindiacentral]="jic"
  [southindia]="soi"
  [westindia]="wei"
  [canadaeast]="cae"
  [uaenorth]="uan"
  [uaecentral]="uac"
  [centraluseuap]="cue"
)

declare -A region_vm_prefixes=(
  [australiaeast]="ae"
  [australiacentral]="ac"
  [australiacentral2]="a2"
  [australiasoutheast]="as"
  [centralus]="cs"
  [eastus]="es"
  [eastus2]="e2"
  [westus]="ws"
  [westus2]="w2"
  [westus3]="w3"
  [southcentralus]="su"
  [westcentralus]="wu"
  [northcentralus]="nu"
  [southeastasia]="sa"
  [eastasia]="ea"
  [westeurope]="we"
  [northeurope]="ne"
  [swedencentral]="sc"
  [uksouth]="us"
  [ukwest]="uw"
  [southafricanorth]="sn"
  [southafricawest]="sw"
  [centralindia]="ci"
  [japaneast]="je"
  [japanwest]="jw"
  [koreacentral]="kc"
  [koreasouth]="ks"
  [canadacentral]="cc"
  [francecentral]="fc"
  [francesouth]="fs"
  [germanywestcentral]="gc"
  [germanynorth]="gn"
  [norwayeast]="we"
  [norwaywest]="ww"
  [switzerlandnorth]="sn"
  [switzerlandwest]="sw"
  [brazilsouth]="bs"
  [brazilsoutheast]="be"
  [jioindiawest]="ji"
  [jioindiacentral]="jc"
  [southindia]="si"
  [westindia]="wi"
  [canadaeast]="ce"
  [uaenorth]="un"
  [uaecentral]="uc"
  [centraluseuap]="ce"
)
###########################
# START OF BASH FUNCTIONS #
###########################

# These functions are being used through out the whole bash script.

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

rm output.txt

if [ -z "$aks_name_purpose" ] || [ -z "$aks_name_identifier" ] || [ -z "$aks_rg_purpose" ] || [ -z "$aks_rg_identifier" ] || [ -z "$aks_rg_name" ]; then
  my_echo "\033[1;37m=====================================================================================================\033[0m"
  my_echo "\033[1;37m= Naming convention variables have not been set in the previous task please review the bash script. =\033[0m"
  my_echo "\033[1;37m=====================================================================================================\033[0m"
  exit 1
fi

# This is used to determine the `location prefix` used in the terraform code for the dynamic naming convention.
aks_resource_groups_block=$(awk '/resource_groups = {/,/}/' terraform.tfvars)
aks_resource_group_location=$(echo "$aks_resource_groups_block" | awk -F'"' '/location =/{print $2}')

aks_block=$(grep -A999 "kubernetes_clusters = {" "terraform.tfvars")
aks_location=$(echo "$aks_block" | awk -F'"' '/resource_group = {/{getline; print}' | awk -F'"' '/location =/{print $2}')

aks_rg_location_prefix="${region_prefixes[$aks_resource_group_location]}"
aks_name_location_prefix="${region_prefixes[$aks_location]}"

if [ -z "$aks_rg_location_prefix" ] || [ -z "$aks_name_location_prefix" ]; then
  my_echo "\033[1;37m=====================================================================================================\033[0m"
  my_echo "\033[1;37m= Naming convention variables have not been set in the previous task please review the bash script. =\033[0m"
  my_echo "\033[1;37m=====================================================================================================\033[0m"
  exit 1
fi

# Dynically build Azure Kubernetes Cluster Resource Group name depending on multiple variabes and bash run-time input selections.
aks_rg_name="rg-$aks_rg_purpose-$environment_prefix-$aks_rg_location_prefix-$aks_rg_identifier"
aks_name="akc-$aks_name_purpose-$environment_prefix-$aks_name_location_prefix-$aks_name_identifier"
if [ -z "$aks_rg_name" ] || [ -z "$aks_rg_name" ]; then
  my_echo "\033[1;37m====================================================\033[0m"
  my_echo "\033[1;37m= Kubernetes Cluster Resource Group: Name not set. =\033[0m"
  my_echo "\033[1;37m====================================================\033[0m"
  exit 1
fi
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

rm resource_group_output.txt

if [ -z "$vmss_name_purpose" ] || [ -z "$vmss_name_identifier" ] || [ -z "$vmss_rg_location" ] || [ -z "$vmss_rg_purpose" ] || [ -z "$vmss_rg_identifier" ]; then
  my_echo "\033[1;37m==============================================================================================================\033[0m"
  my_echo "\033[1;37m= Block 1: Naming convention variables have not been set in the previous task please review the bash script. =\033[0m"
  my_echo "\033[1;37m==============================================================================================================\033[0m"
  exit 1
fi

# This is used to determine the `location prefix` used in the terraform code for the dynamic naming convention.
vmss_resource_groups_block=$(awk '/resource_groups = {/,/}/' terraform.tfvars)
vmss_resource_group_location=$(echo "$vmss_resource_groups_block" | awk -F'"' '/location =/{print $2}')

vmss_block=$(grep -A999 "linux_virtual_machine_scale_sets = {" "terraform.tfvars")
vmss_location=$(echo "$vmss_block" | awk -F'"' '/resource_group = {/{getline; print}' | awk -F'"' '/location =/{print $2}')

vmss_rg_location_prefix="${region_prefixes[$vmss_resource_group_location]}"
vmss_name_location_prefix="${region_prefixes[$vmss_location]}"
vmss_name_vm_prefix="${region_vm_prefixes[$vmss_location]}"

if [ -z "$vmss_rg_location_prefix" ] || [ -z "$vmss_name_location_prefix" ] || [ -z "$vmss_name_vm_prefix" ]; then
  my_echo "\033[1;37m==============================================================================================================\033[0m"
  my_echo "\033[1;37m= Block 2: Naming convention variables have not been set in the previous task please review the bash script. =\033[0m"
  my_echo "\033[1;37m==============================================================================================================\033[0m"
  exit 1
fi

# Dynically build Azure Virtual Machine Scale Set Resource Group name depending on multiple variabes and bash run-time input selections.
vmss_rg_name="rg-$vmss_rg_purpose-$environment_prefix-$vmss_rg_location_prefix-$vmss_rg_identifier"

if [ -z "$vmss_rg_name" ]; then
  my_echo "\033[1;37m=================================================\033[0m"
  my_echo "\033[1;37m= Virtual Machine Resource Group: Name not set. =\033[0m"
  my_echo "\033[1;37m=================================================\033[0m"
  exit 1
fi
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

##################################################
# START OF BASH SCRIPT AFTER EXPRESSIONAL CHECKS #
##################################################

az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" --output none

if [ $? -ne 0 ]; then
  my_echo "\033[1;37m===============================================================================\033[0m"
  my_echo "\033[1;37m= Error: Azure login failed. Please check your service principal credentials. =\033[0m"
  my_echo "\033[1;37m===============================================================================\033[0m"
  exit 1
fi

az account set --subscription "$ARM_SUBSCRIPTION_ID" --output none

if [ $? -ne 0 ]; then
  my_echo "\033[1;37m============================================================================\033[0m"
  my_echo "\033[1;37m= Error: Azure subscription set failed. Please check your subscription ID. =\033[0m"
  my_echo "\033[1;37m============================================================================\033[0m"
  exit 1
fi

service_principal_object_id=$(az ad sp show --id "$ARM_CLIENT_ID" --query servicePrincipalNames -o tsv)
role_assignment=$(az role assignment list --assignee "$service_principal_object_id" --scope "/subscriptions/$ARM_SUBSCRIPTION_ID" --query "[?roleDefinitionName=='Contributor']" -o json)

if [ -n "$role_assignment" ]; then
    my_echo "\033[1;37m=============================================================================\033[0m"
    my_echo "\033[1;37m= The service principal has the \033[0;33mContributor \033[1;37mrole on the Azure subscription. =\033[0m"
    my_echo "\033[1;37m=============================================================================\033[0m"
else
    my_echo "\033[1;37m=======================================================================================\033[0m"
    my_echo "\033[1;37m= The service principal does not have the \033[0;33mContributor \033[1;37mrole on the Azure subscription. =\033[0m"
    my_echo "\033[1;37m=======================================================================================\033[0m"
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

if [ "$deploy_terraform_apply" = false ]; then
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
else
  my_echo "\033[1;37m===============================================================\033[0m"
  my_echo "\033[1;37m= Terraform plan is skipped as -plan option was not provided. =\033[0m"
  my_echo "\033[1;37m===============================================================\033[0m"
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

  rm -f "$1-$environment_prefix-plan.out"
  delete_deployment_files

  if [ $? -ne 0 ]; then
    my_echo "\033[1;37m===========================================================\033[0m"
    my_echo "\033[1;37m= Error: Terraform apply failed. Deployment unsuccessful. =\033[0m"
    my_echo "\033[1;37m===========================================================\033[0m"
    rm -f "$1-$environment_prefix-plan.out"
    delete_deployment_files
    exit 1
  fi
else
  my_echo "\033[1;37m============================================================\033[0m"
  my_echo "\033[1;37m= Terraform apply is skipped as -plan option was provided. =\033[0m"
  my_echo "\033[1;37m============================================================\033[0m"
  rm -f "$1-$environment_prefix-plan.out"
  delete_deployment_files
fi

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
  if [ -z "$vmssList" ]; then
      my_echo "\033[1;37m  No VMSS instances found. Exiting script.\033[0m"
      exit 1
  else
      my_echo "\033[1;37m               \033[0;33m$vmssList                   \033[0m"
  fi

  for vmssName in $vmssList; do
    vmssInstances=$(az vmss list-instances --resource-group $vmss_rg_name --name $vmssName --query "[].{Name:name}" --output tsv)
    for instanceInfo in $vmssInstances; do
      instanceName="${instanceInfo%_*}"
      instanceId="${instanceInfo##*_}"
      publicIpAddress=$(az vmss list-instance-public-ips --resource-group $vmss_rg_name --name $vmssName --query "[?contains(id, '/$instanceId/')].ipAddress" --output tsv)
      
      echo
      my_echo "\033[1;37m============================================================\033[0m"
      my_echo "\033[1;37m= Please wait for VMSS to finish updating and go online... =\033[0m"
      my_echo "\033[1;37m============================================================\033[0m"
      my_echo "\033[1;37m                      \033[0;33m$vmssList                   \033[0m"

      if curl -k -s --head "https://$publicIpAddress" | grep "HTTP/1.1 200 OK\|HTTP/2 200"; then
          my_echo "\033[1;37mWebsite \033[0;33mhttps://$publicIpAddress \033[1;37m Website is reachable. Skipping countdown.\033[0m"
      else
          check_https_status() {
            local response
            response=$(curl -sIk "https://$publicIpAddress" | grep "HTTP/1.1 200 OK\|HTTP/2 200")
            if [ -n "$response" ]; then
                return 0
            else
                return 1
            fi
          }
          max_retries=10
          sleep_interval=20
          retry_count=0
          while [ $retry_count -lt $max_retries ]; do
              if check_https_status; then
                  my_echo "\033[1;37mHTTPS HEAD request successful."
                  break
              else
                  my_echo "\033[1;37mServer HTTPS is still being set up. Retrying in \033[0;33m$sleep_interval seconds...\033[1;37m"
                  sleep $sleep_interval
                  retry_count=$((retry_count + 1))
              fi
          done
      fi
      
      htmlContent=$(curl -k -s https://$publicIpAddress | grep -o '<title>.*</title>' | sed -e 's/<title>//;s/<\/title>//;s/<!.*>//g' | awk 'NF')
      if echo "$htmlContent" | grep -q "Hello, World!\|Hello, World from Ansible"; then
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

  ######################################
  # Ansible Section of the Bash Script #
  ######################################

  if echo "$htmlContent" | grep -q "Hello, World from Ansible"; then
    my_echo "\033[1;37mYou have already deployed the ansible playbook to: \033[0;33mhttps://$publicIpAddress\033[0m"
  else
    read -p "Do you want to update nginx webpage with an Ansible playbook (y/n)? " answer
  fi

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
  entry_to_add="$publicIpAddress ansible_user=$ansible_user ansible_ssh_private_key_file=/$HOME/.ssh/azure"

  if ! grep -qF "$entry_to_add" "$hosts_file"; then
      # Add the entry if it doesn't exist
      sed -i "/^\[azure_vm\]/a $entry_to_add" "$hosts_file"
      my_echo "\033[1;37mEntry added to \033[0;33mhosts.ini\033[0m"
  else
      my_echo "\033[1;37mEntry already exists in \033[0;33mhosts.ini\033[1;37m, Skipping.\033[0m"
  fi
  #sed -i "/^\[azure_vm\]/a $publicIpAddress ansible_user=adminuser ansible_ssh_private_key_file=/$HOME/.ssh/azure" $hosts_file
  # Check if [azure_vm] exists in the file
  cd ../../../../ansible/playbooks
  PYTHONWARNINGS="ignore" ansible-playbook -i ../inventory/hosts.ini update_nginx.yml
  if [ $? -ne 0 ]; then
      my_echo "\033[1;37m=======================================================================\033[0m"
      my_echo "\033[1;37m= Ansible playbook execution failed please check your hosts.ini file. =\033[0m"
      my_echo "\033[1;37m=======================================================================\033[0m"
  else
      my_echo "\033[1;37m===========================================\033[0m"
      my_echo "\033[1;37m= Ansible playbook executed successfully. =\033[0m"
      my_echo "\033[1;37m===========================================\033[0m"
  fi
  htmlContent=$(curl -k -s https://$publicIpAddress | grep -o '<title>.*</title>' | sed -e 's/<title>//;s/<\/title>//;s/<!.*>//g' | awk 'NF')
  if echo "$htmlContent" | grep -q "Hello, World from Ansible"; then
    my_echo "\033[1;37m Webpage has been updated to: \033[0;33m$htmlContent\033[1;37m on \033[0;33mhttps://$publicIpAddress\033[0m"
  fi
  my_echo "\033[1;37m==============================\033[0m"
  my_echo "\033[1;37m= Script has been completed. =\033[0m"
  my_echo "\033[1;37m==============================\033[0m"
  exit 1
fi

#########################################
# Kubernetes Section of the Bash Script #
#########################################

if [ "$deploy_terraform_apply" = true ] && [ "$destroy_terraform" = false ] && [ "$1" = "kubernetes_cluster" ]; then

  dynamically_generate_kubernetes_cluster_resource_values

  az aks show --resource-group $aks_rg_name --name $aks_name --query 'id' --output tsv >/dev/null 2>&1

  if [ $? -ne 0 ]; then
    my_echo "\033[1;37m===============================================================\033[0m"
    my_echo "\033[1;37m= No Azure Kubernetes Cluster resource found. Exiting script. =\033[0m"
    my_echo "\033[1;37m===============================================================\033[0m"
    exit 1
  fi

  my_echo "\033[1;37m====================================================\033[0m"
  my_echo "\033[1;37m= Preparing to Deploy the Kubernetes Manifest File =\033[0m"
  my_echo "\033[1;37m====================================================\033[0m"

  if ! command_exists kubectl; then
      my_echo "\033[1;37m===========================================================\033[0m"
      my_echo "\033[1;37m= Error: 'kubectl' command not found. Installing kubectl. =\033[0m"
      my_echo "\033[1;37m===========================================================\033[0m"
  fi


  if ! az aks get-credentials --resource-group $aks_rg_name --name $aks_name --overwrite-existing > /dev/null 2>&1; then
    my_echo "\033[1;37m=======================================================================================================\033[0m"
    my_echo "\033[1;37m= Error: Failed to get AKS credentials. Please check your Azure CLI configuration and resource names. =\033[0m"
    my_echo "\033[1;37m=======================================================================================================\033[0m"
    exit 1
  fi

  if ! kubectl get nodes; then
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
  pod_ip=$(kubectl get svc nginx-hello-world -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  if curl -s --head "http://$pod_ip" | grep "HTTP/1.1 200 OK\|HTTP/2 200"; then
      my_echo "\033[1;37mWebsite \033[0;33mhttp://$pod_ip \033[1;37m Website is reachable. Skipping countdown.\033[0m"
  else
      check_http_status() {
        local response
        response=$(curl -sI "http://$pod_ip" | grep "HTTP/1.1 200 OK\|HTTP/2 200")
        if [ -n "$response" ]; then
            return 0  # Success
        else
            return 1  # Failure
        fi
      }
      retry_count=0
      max_retries=10
      sleep_interval=26
      while [ $retry_count -lt $max_retries ]; do
          if check_http_status; then
              my_echo "\033[1;37mHTTP HEAD request successful.\033[0m"
              break
          else
              my_echo "\033[1;37mHTTP Server is still being setup. Retrying in $sleep_interval seconds...\033[0m"
              sleep $sleep_interval
              retry_count=$((retry_count + 1))
          fi
      done
      pod_ip=$(kubectl get svc nginx-hello-world -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  fi

  my_echo "\033[1;37m======================================================================"
  my_echo "\033[1;37m    Kubernetes Pod Nginx Server is Live at: \033[0;33mhttp://$pod_ip\033[0m"
  my_echo "\033[1;37m======================================================================"
fi