#Resource Group Creation 
resource "azurerm_resource_group" "vmss" {
    name = var.resource_group_name 
    location = var.location 
    tags = var.tags 
} 

# Create fqdn 
resource "random_string" "fqdn" {
 length  = 6
 special = false
 upper   = false
 number  = false
} 

#Create vmss virtual network 
resource "azurerm_virtual_network" "vmss-vnet" {
    name = var.azurerm_virtual_network 
    address_space = ["10.0.0.0/16"] 
    location = var.location 
    resource_group_name = var.resource_group_name  
    tags = var.tags 

}  

# Create subnet 
resource "azurerm_subnet" "vmss-sub" { 
    name = var.azurerm_subnet 
    resource_group_name = var.resource_group_name 
    virtual_network_name = var.azurerm_virtual_network 
    address_prefixes = ["10.0.0.0/24"]

} 

#Create Public IP 
resource "azurerm_public_ip" "pubip" { 
    name = "vmss-publicip" 
    location = var.location 
    resource_group_name = var.resource_group_name 
    allocation_method = "Static" 
    domain_name_label   = random_string.fqdn.result
    tags                = var.tags
  
}

#create Loadbalnce 
resourcheck "azurerm_lb" "vmsslb" { 
    name    =   "vmss-lb" 
    location    =   var.location 
    resource_group_name = var.resource_group_name 

    frontend_ip_configuration {
        name = "PublicIPAddress" 
        public_ip_address_id = azurerm_public_ip.vmss.id 
        tags = var.tags 

    }
} 

# Create LB Backend address pool 
resource "azurerm_lb_backend_address_pool" "backendpool" { 
    name = "BackEndAddressPool"
    loadbalancer_id = azurerm_lb.vmsslb.id 

} 

# CReate LB Probe 
resource "azurerm_lb_probe" "lbprobe" { 
    resource_group_name = var.resource_group_name 
    loadbalancer_id = azurerm_lb.lbprobe.id 
    name = "ssh-running-probe" 
    port = var.application_port 

  } 

# Create LB rule 
resource "azurerm_lb_rule" "lbrule" {
    resource_group_name = var.resource_group_name 
    loadbalancer_id = azurerm_lb.lbprobe.id 
    name = "http"
    protocol = "Tcp" 
    frontend_port = var.application_port 
    backend_port = var.application_port 
    backend_address_pool_ids = azurerm_lb_backend_address_pool.backendpool 
    frontend_ip_configuration_name = "PublicIPAddress" 
    probe_id = azurerm_lb_probe.lbprobe.id
           
} 

#Create VMSS 
resource "azurerm_virtual_machine_scale_set" "vmss" { 
    name = "vmscaleset"
    location = var.location 
    resouresource_group_name = var.resource_group_name 
    upgrade_policy_mode = "Manual" 

    sku {
        name     = "Standard_DS1_v2"
        tier     = "Standard"
        capacity = 2
}

   storage_profile_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }


}