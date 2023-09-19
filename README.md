# SRE_Test
This repository has been created to deploy a Azure Kuberenetes Cluster on Azure using Azure DevOps Pipelines.

---

## What this repository does

### **Summary:**

1. Create an auto scaling web server using a Virtual Machine in Azure with a `Hello World` webpage. 
2. Use Terraform to deploy a Kubernetes cluster in Azure
3. Use ansible utilizing playbooks to manually apply to all currently running virtual machines.

---

## Deployment Options

1. Manual Deployment using Azure Service Principal

**Step 1:** Export Environment Variables (Linux Operating system)

```bash
export ARM_CLIENT_ID="$TF_VAR_service_principal_id"
export ARM_CLIENT_SECRET="$TF_VAR_service_principal_secret"
export ARM_SUBSCRIPTION_ID="YourSubscriptionId"
export ARM_TENANT_ID="YourAzureADTenantId"
``` 

**Step 2:** Clone the repository locally.

```bash
git clone https://github.com/DFW1N/SRE_Test && cd SRE_Test/scripts
```


**Step 3:** Execute the bash script.

```bash
chmod 700 azure_manual_deployment.sh
./azure_manual_deployment.sh <input_value>
```
> NOTE: When you run the shell script it will require you to input a required value that must be either `virtual_machine` or `kubernetes_cluster`.

3. Azure DevOps Pipelines

```bash

```

---

## Deployment Process

Please follow the steps below to deploy the infrastructure.

Step 1:

---

## Directory Structure

The repository has been broken down into directories with the following:

```bash
pipelines/
terraform/
   main/
   layers/
      assets/
      modules/
```
---

### References:

> Please keep in mind some of the links are top level domains that were used to pull multiple resources from this is subjective depending on the link reference.

1. [Terraform AzureRM Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

---

###

Author: Sacha Roussakis-Notter
