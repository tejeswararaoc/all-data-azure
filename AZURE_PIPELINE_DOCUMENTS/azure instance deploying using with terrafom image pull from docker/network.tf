# REsource group creation
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
# Create Virtual Network

resource "azurerm_virtual_network" "vn" {
  name                = "vn-vnetwork"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

#Create a subnet

resource "azurerm_subnet" "azsub" {
  name                 = "azsub-name"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Public IP
resource "azurerm_public_ip" "mypublicip" {
  name = "publicip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
} 

# Create network Security Group
resource "azurerm_network_security_group" "sg1" {
  name                = "sg1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}