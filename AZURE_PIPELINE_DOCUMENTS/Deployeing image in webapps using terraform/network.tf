# Generate a random integer to create a globally unique name 
resource  "random_integer" "r1" {
    min = 10000
    max = 99999
} 

# create a resource group  
resource "azurerm_resource_group" "r1" {
 
    name = "myResourceGroup-${random_integer.r1.result}"
    location = "eastus"
} 

# Create the Linux App Service Plan 
resource "azurerm_resource_plan" "appserviceplan" {
    name = "webapp-asp-${random_integer.r1.result}" 
    locatioon = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name 
    os_type = "Linux" 
    sku_name = "B1" 
} 

# Create the WEb app pass in the App service plan ID 
resource  "azurerm_linux_web_app" "webapp" { 
    name = "webapp-${random_integer.r1.result}" 
    location = azurerm_resource_group.rg.location 
    resource_group_name = azurerm_resource_group.rg.name 
    service_plan_id       = azurerm_service_plan.appserviceplan.id 
    http_only            = true 
    site_config { 
    minimum_tls_version = "1.2"
  }

} 

#  Deploy code from a public GitHub repo  

resource "azurerm_app_service_source_control" "sourcecontrol" {
    app_id = azurerm_linux_web_app.webapp.id 
    repo_url = "https://github.com/Azure-Samples/nodejs-docs-hello-world" 
    branch = "master" 
    use_manual_integration = true
    use_mercurial      = false
}




