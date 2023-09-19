#============================================================================#
#                                                                            #
# ███████╗██████╗ ███╗   ██╗██╗███████╗                                      #
# ██╔════╝██╔══██╗████╗  ██║██║██╔════╝  # Author: Sacha Roussakis-Notter    #
# ███████╗██████╔╝██╔██╗ ██║██║█████╗    # Lisence: MIT                      #
# ╚════██║██╔══██╗██║╚██╗██║██║██╔══╝    # Date Created: 03/07/2022          #
# ███████║██║  ██║██║ ╚████║██║██║       # Framework: SRNIF                  #
# ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝                                           #
# Copyright (c) 2022, Sacha Roussakis-Notter                                 #
#                                                                            #
# ===========================================================================#

resources = {

    global_prefixes = {
        general = {
            location = "australiaeast"
            projectName = "sre"
        }
    }

    resource_types = {
        rgResourceType = "rg" # Resource Group
        lkResourceType = "lk" # Management Lock
        vmResourceType = "vm" # Virtual Machine
        nsgResourceType = "nsg" # Network Security Group
        vntResourceType = "vnt" # Virtual Network
        sntResourceType = "snt" # Subnet
        lawResourceType = "law" # Log Analytics Workspace
        wksResourceType = "wks" # Workspace
        stoResourceType = "sto" # Storage Account
        dskResourceType = "dsk" # OS Disk
        kmsResourceType = "kms" # Key Vault
        pwdResourceType = "pwd" # Password
        srtResourceType = "srt" # Secret
        nicResourceType = "nic" # Network Interface Card
        pipResourceType = "pip" # Public Ip Address
        ipResourceType = "ip" # Ip Address
        rtResourceType = "rt" # Route Table
        arlResourceType = "arl" # Authorization Rule
        mdsResourceType = "mds" # Azure Monitor Diagnostic Settings
        dosResourceType = "dos" # Distrubited Denial of Service
        plnResourceType = "pln" # Plan
        ehnResourceType = "ehn" # Event Hub Namespace
        ehResourceType = "eh" # Event Hub
        alaResourceType = "ala" # Activity Log Alert
        lerResourceType = "ler" # Log Analytics Data Export Rule
        smpResourceType = "smp" # Storage Management Policy
        ktcResourceType = "ktc" # Kusto Clusters
        kdbResourceType = "kdb" # Kusto Cluster Databases
        kpaResourceType = "kpa" # Kusto Principal Assignments
        cmeResourceType = "cme" # Cost Management Export
        ppgResourceType = "ppg" # Proximity Placement Group
        agwResourceType = "agw" # Application Gateway
        basResourceType = "bas" # Azure Bastion Host
        rsvResourceType = "rsv" # Azure Recovery Service Vault
        vmbResourceType = "vmb" # Azure Recovery Service Vault Virtual Machine Backup
        asgResourceType = "asg" # Application Security Group
        avsResourceType = "avs" # Availability Set
        mgdResourceType = "mgd" # Virtual Machine Managed Disk
        aspResourceType = "asp" # Azure Service Plan
        assResourceType = "ass" # Azure Static Site
        lwpResourceType = "lwp" # Linux Web App
        wwaResourceType = "wwa" # Windows Web App
        crgResourceType = "crg" # Capacity Reservation Group
        dhgResourceType = "dhg" # Dedicated Host Group
        ddhResourceType = "ddh" # Dedicated Host
        vwnResourceType = "vwn" # Virtual Wan
        svpResourceType = "svp" # Service Plan
        lfaResourceType = "lfa" # Linux Function App
        lwaResourceType = "lwa" # Linux Web App
        akcResourceType = "akc" # Azure Kubernetes Cluster
        kcnResourceType = "kcn" # Azure Kubernetes Cluster Node
        uadResourceType = "uad" # User Assigned Identity
        vhbResourceType = "vhb" # Virtual Hub
        vwnResourceType = "vwn" # Virtual Wan
        vgwResourceType = "vgw" # VPN Gateway
        vngResourceType = "vng" # Virtual Network Gateway
        acrResourceType = "acr" # Azure Container Registry
        sigResourceType = "sig" # Shared Image Gallery
        peResourceType = "pe" # Private Endpoint
        pscResourceType = "psc" # Private Service Connection
    }

    azure_locations = {
        regions = {
            australiaeast = "aue"
            australiacentral = "auc"
            australiacentral2 = "ac2"
            australiasoutheast = "ase"
            centralus = "cus"
            eastus = "eus"
            eastus2 = "eu2"
            westus = "wus"
            westus2 = "wu2"
            westus3 = "wu3"
            southcentralus = "scu"
            westcentralus = "wcu"
            northcentralus = "ncu"
            southeastasia = "sea"
            eastasia = "eaa"
            westeurope = "weu"
            northeurope = "noe"
            swedencentral = "swc"
            uksouth = "uks"
            ukwest = "ukw"
            southafricanorth = "san"
            southafricawest = "saw"
            centralindia = "cei"
            japaneast = "jae"
            japanwest = "jaw"
            koreacentral = "koc"
            koreasouth = "kos"
            canadacentral = "cac"
            francecentral = "frc"
            francesouth = "frs"
            germanywestcentral = "gwc"
            germanynorth = "gen"
            norwayeast = "nwe"
            norwaywest = "now"
            switzerlandnorth = "sln"
            switzerlandwest = "sww"
            brazilsouth = "brs"
            brazilsoutheast = "bse"
            jioindiawest = "jiw"
            jioindiacentral = "jic"
            southindia = "soi"
            westindia = "wei"
            canadaeast = "cae"
            uaenorth = "uan"
            uaecentral = "uac"
            centraluseuap = "cue"
        }
        vm_regions = {
            australiaeast = "ae"
            australiacentral = "ac"
            australiacentral2 = "a2"
            australiasoutheast = "as"
            centralus = "cs"
            eastus = "es"
            eastus2 = "e2"
            westus = "ws"
            westus2 = "w2"
            westus3 = "w3"
            southcentralus = "su"
            westcentralus = "wu"
            northcentralus = "nu"
            southeastasia = "sa"
            eastasia = "ea"
            westeurope = "we"
            northeurope = "ne"
            swedencentral = "sc"
            uksouth = "us"
            ukwest = "uw"
            southafricanorth = "sn"
            southafricawest = "sw"
            centralindia = "ci"
            japaneast = "je"
            japanwest = "jw"
            koreacentral = "kc"
            koreasouth = "ks"
            canadacentral = "cc"
            francecentral = "fc"
            francesouth = "fs"
            germanywestcentral = "gc"
            germanynorth = "gn"
            norwayeast = "we"
            norwaywest = "ww"
            switzerlandnorth = "sn"
            switzerlandwest = "sw"
            brazilsouth = "bs"
            brazilsoutheast = "be"
            jioindiawest = "ji"
            jioindiacentral = "jc"
            southindia = "si"
            westindia = "wi"
            canadaeast = "ce"
            uaenorth = "un"
            uaecentral = "uc"
            centraluseuap = "ce"
        }
    }

    virtual_machines = {
        redhat = {
            osType = "Linux"
            publisher = "RedHat"
            offer = "RHEL"
            sku = "8.2"
            version = "latest"
        }

        ubuntu = {
            osType = "Linux"
            publisher = "Canonical"
            offer = "UbuntuServer"
            sku = "18.04-LTS"
            version = "latest"
        }

        windowsServer = {
            osType = "Windows"
            publisher = "MicrosoftWindowsServer"
            offer = "WindowsServer"
            sku = "2019-Datacenter"
            version = "latest"
        }

        windowsDesktop = {
            osType = "Windows"
            publisher = "MicrosoftWindowsDesktop"
            offer = "Windows-10"
            sku = "21h1-ent"
            version = "latest"
        }
    }
}
