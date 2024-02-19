#VMSS

resource "azurerm_linux_virtual_machine_scale_set" "myvmss" {
  name                = var.vmss_name.name
  resource_group_name = azurerm_resource_group.MYRGP.name
  location            = azurerm_resource_group.MYRGP.location
  instances           = var.vmss_name.numberofinstance
  sku                 = local.skusize 
  admin_username = var.vmss_name.username
  os_disk {
    storage_account_type = local.storage_account_type
    caching              = local.caching
  }
     admin_ssh_key {
    username   = var.vmss_name.username
    public_key = file("~/.ssh/id_rsa.pub")
  }
   source_image_reference {
    publisher = local.publisher
    offer     = local.offer
    sku       = local.sku
    version   = local.version
   }
   
   network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = local.network_interface_name
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
  tags = {
    environment = terraform.workspace
  }
  depends_on = [
    azurerm_resource_group.MYRGP,
    azurerm_subnet.internal
  ]

  
} 

### REsource Group 

resource "azurerm_resource_group" "MYRGP" {
    name = var.group_info 
    location = var.location_info 
} 

### Provider 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
} 

#  Network 

resource "azurerm_virtual_network" "myvnet" {
    name = var.vnet_info.name
    address_space =var.vnet_info.address_space
    location = azurerm_resource_group.MYRGP.location
    resource_group_name = azurerm_resource_group.MYRGP.name
    depends_on = [
      azurerm_resource_group.MYRGP
    ]
   }
  resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.MYRGP.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["192.168.1.0/24"]
  depends_on = [
    azurerm_virtual_network.myvnet
  ]
  
}
resource "azurerm_public_ip" "lb_pubip" {
  name                = "lb_frontpool_public_ip"
  location            = azurerm_resource_group.MYRGP.location
  resource_group_name = azurerm_resource_group.MYRGP.name
  allocation_method   = "Dynamic"
   

  tags = {
    environment = terraform.workspace
  }
} 

# ### modeules 

# module "vmss" {
#   source  = "rahulagalcha97/vmss/azurerm"
#   version = "0.1.16"
#   # insert the 2 required variables here
# }  

## locals.tf 

locals {
  #first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
   skusize = "Standard_F2"
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    network_interface_name = "myvmss"
} 

##loadbalance 

resource "azurerm_lb" "my_lb" {
  name                = "mylb"
  resource_group_name = azurerm_resource_group.MYRGP.name
    location = azurerm_resource_group.MYRGP.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pubip.ip_address
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id     = azurerm_lb.my_lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.MYRGP.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.my_lb.id
  protocol                       = "All"
  frontend_port_start            = 80
  frontend_port_end              = 80
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "my_healthprob" {
  
  loadbalancer_id     = azurerm_lb.my_lb.id
  name                = "http-probe"
  protocol            = "Tcp"
  port                = 80
} 

### variable 

variable "group_info" {
  type        = string
  default     = "defaultresourcegroup"
  description = "(optional) describe your variable"
}
variable "location_info" {
  type =  string
  default = "eastus"

}
variable "vnet_info" {
  type = object({
    name          = string
    address_space = list(string)
  })
  default = {
    address_space = ["10.0.0.1/16"]
    name          = "myvnetfromtf"
  }
}
variable "vmss_name" {
    type = object({
        name = string
        username = string
        numberofinstance = number
    })
} 

## Backend 

terraform {
  backend "azurerm" {

    resource_group_name  = "storageaccount"
    storage_account_name = "terraformbackend12"
    container_name       = "mycontainer"
    key                  = "ntirekey"

  }

}   

## 