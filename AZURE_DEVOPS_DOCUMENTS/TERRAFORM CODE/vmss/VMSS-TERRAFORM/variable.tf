# Create REsource group
variable "resource_group_name" { 
    description = "Name of the Resource group" 
    default = "teja"
  
} 

# Create Location 
variable "location" {
  description = "Location where resource will be create" 
  default = "eastus"
} 

# Create Tags 
variable "tags" { 
    description = "map of tagas creation to resource"
    type = map (string) 
    default = {
      environment = "dev"
    }
}  

# Create Vnet
variable "azurerm_virtual_network" { 
    description = "name of virtual network" 
    default = "vmss-vnet"
} 
#Create subnet 
variable "azurerm_subnet" { 
    description = "name of subent" 
    default = "vmss-sub"
}  

#Create Application Port 
variable "application_port" { 
    description = "Port that you want to expose to the external load balancer"
    default     = 80
   
} 

#Create user name 
variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "azureuser"
} 

#Create password 

variable "admin_password" {
   description = "Default password for admin account" 
   default = "India@1947"
}