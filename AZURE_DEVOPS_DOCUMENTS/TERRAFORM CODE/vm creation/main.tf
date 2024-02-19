resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "Central India"
} 
 
resource "azurerm_virtual_network" "vnetwork" {
  name                = "vnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "mysub" {
  name                 = "mysub"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
} 

resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "pubip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic" 
} 

resource "azurerm_network_security_group" "sg" {
  name                = "sg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name 


    security_rule {
    name                       = "ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.mysub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vmpra" {
  name                  = "vmpra"
  admin_username        = "azureuser"
  admin_password        = "teja@12345678"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s" 
  disable_password_authentication = false

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2" 
    version   = "latest" 
    
  }

} 

# resource "null_resource" "cluster" {
#   # Changes to any instance of the cluster requires re-provisioning
#   triggers = {
#     version = "1"
#   }
# }
#   # Bootstrap script can run on any instance of the cluster
#   # So we just choose the first in this case

# resource "aws_instance" "web" {
#   # ...

#   # Establishes connection to be used by all
#   # generic remote provisioners (i.e. file/remote-exec)
#   connection {
#     type     = "ssh"
#     user     = "root"
#     password = var.root_password
#     host     = self.public_ip
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "puppet apply",
#       "consul join ${aws_instance.web.private_ip}",
#     ]
#   }
# }


# provisioner "file" {
#   source      = "bash.sh"
#   destination = "/home/azureuser/bash.sh"

#   connection {
#     type     = "ssh"
#     user     = "azureuser"
#     password = "teja@12345678"
#     host     = "azurerm_public_ip.my_terraform_public_ip.id"
#   } 

# provisioner "remote-exec" { 
#      connection {
#     type     = "ssh"
#     user     = "azureuser"
#     password = "teja@12345678"
#     host     = "azurerm_public_ip.my_terraform_public_ip.id"
#   } 
#      inline = [
#      "ls -a", 
#      "sudo chmod +x bash.sh" 
#      "sudo ./bash.sh"
#        "consul join ${aws_instance.web.private_ip}",
#     ]
#    }
#  provisioner "local-exec" {
#     command = "echo ${azurerm_public_ip.my_terraform_public_ip.id} >> private_ips.txt"
#   }

# }


