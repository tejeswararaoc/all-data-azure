# Creation of Azure Container for NGINX

resource "azurerm_container_group" "mycontainer" {
    name                =    "mycontainer-TEja"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ip_address_type     = "Public"
    # dns_name_label      = "aci-label"
    # subnet_ids          = [azurerm_subnet.azsub-name.id]
    os_type             = "Linux"



image_registry_credential {
    username = "tejaaws"
    password = "ttt@123456789"
    server   = "hub.docker.com"
  }

container {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = "1"
    memory = "1.5"


    #restart_policy = "Always"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }