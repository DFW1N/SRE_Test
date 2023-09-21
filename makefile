.PHONY: setup install-terraform install-azure-cli install-yq install-ansible install-git install-kubectl install-all

install-all: setup install-terraform install-azure-cli install-yq install-ansible install-git install-kubectl

setup:
		sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

install-terraform:
		wget -O- https://apt.releases.hashicorp.com/gpg | \
		gpg --dearmor | \
		sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
		gpg --no-default-keyring \
		--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
		--fingerprint
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
		https://apt.releases.hashicorp.com $(shell lsb_release -cs) main" | \
		sudo tee /etc/apt/sources.list.d/hashicorp.list
		sudo apt update
		sudo apt-get install terraform -y
		@terraform --version >/dev/null 2>&1 && echo "Terraform installed successfully."

install-azure-cli:
		curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
		@az --version >/dev/null 2>&1 && echo "Azure CLI installed successfully."

install-yq:
		wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
		chmod +x /usr/bin/yq
		@yq --version >/dev/null 2>&1 && echo "YQ installed successfully."

install-ansible:
		sudo apt-add-repository ppa:ansible/ansible -y
		sudo apt update -y
		sudo apt install ansible -y
		@ansible --version >/dev/null 2>&1 && echo "Ansible installed successfully."

install-git:
		sudo apt update -y
		sudo apt install git -y
		git --version
		@git --version >/dev/null 2>&1 && echo "Git installed successfully."

install-kubectl:
		sudo az aks install-cli
		@kubectl version --client >/dev/null 2>&1 && echo "kubectl installed successfully."