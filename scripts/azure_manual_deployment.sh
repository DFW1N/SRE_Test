#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#!/bin/bash

# Log in to Azure using the service principal
az login --service-principal --username "$service_principal_id" --password "$service_principal_secret" --tenant "$tenant_id"

# Set the Azure subscription
az account set --subscription "$subscription_id"

