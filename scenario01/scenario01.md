# Azure Infrastructure Deployment with Terraform

This project uses Terraform to deploy a comprehensive Azure infrastructure as depicted in the provided architecture diagram. The infrastructure includes multiple virtual networks, subnets, network security groups, virtual machines, and an Event Grid topic.

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0 or later
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Project Structure

├── main.tf
├── variables.tf
├── terraform.tfvars
└── README.md


- `main.tf`: Main Terraform configuration file defining all the resources.
- `variables.tf`: File containing variable definitions.
- `terraform.tfvars`: File containing variable values specific to the deployment.
- `README.md`: Project documentation.

## Configuration

### variables.tf

This file contains the variable definitions used in the Terraform configuration.

### terraform.tfvars

Set the values of the variables in this file:

```hcl
location                 = "East US"
rg_controlplane_name     = "Control-Plane-SCE01"
rg_sce01_name            = "SCE01-Location01"
vnet_controlplane_name   = "ControlPlane"
vnet_controlplane_address_space = ["172.16.0.0/24"]
vnet_dmzlan_name         = "dmzvlan"
vnet_dmzlan_address_space = ["10.0.3.0/24"]
vnet_layer2_name         = "layer2"
vnet_layer2_address_space = ["10.0.2.0/24"]
vm_admin_username        = "adminuser"
vm_admin_password        = "Password1234!"
ubuntu_vm_size           = "Standard_B2s"
windows_vm_size          = "Standard_B2ms"
```


## Deployment
Follow these steps to deploy the infrastructure:

### Authenticate with Azure CLI:

```sh
az login
```

Initialize Terraform:

```sh
terraform init
```

Apply the Configuration:

```sh
terraform apply -auto-approve
```

This will deploy all the resources as specified in the main.tf configuration file.


## Resources Deployed
Resource Groups:

Control-Plane-SCE01
SCE01-Location01
Virtual Networks and Subnets:

ControlPlane
Subnet: controlplane-subnet
dmzvlan
Subnet: bastion
Subnet: layer3-firewall
Subnet: dmz
layer2
Subnet: layer2-subnet
Network Security Groups (NSGs):

NSG-Bastion
NSG-dmzlan
NSG-layer2
Azure Firewall:

azfirewall-01
Route Tables:

routetable-controlplane
routetable-dmzlan
routetable-layer2
Virtual Machines:

Ubuntu VMs in dmzvlan
SCE01VM01, SCE01VM02, SCE01VM03, SCE01VM04, SCE01VM05, SCE01VM06
Windows VMs in layer2
SCE01VM07, SCE01VM08
Event Grid Topic:

example-eventgrid-topic
Clean Up
To destroy all the resources created by this Terraform configuration, run:

sh
Copy code
terraform destroy -auto-approve
Notes
Ensure you have appropriate permissions to create resources in your Azure subscription.
Modify the terraform.tfvars file to customize the configuration for your environment.