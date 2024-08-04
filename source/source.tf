resource "azurerm_network_security_group" "this" {
  location            = var.vnet_location
  name                = "test-${random_id.this.hex}-nsg"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "test-${random_id.this.hex}-rg"
}

resource "azurerm_route_table" "this" {
  location            = var.vnet_location
  name                = "test-${random_id.this.hex}-rt"
  resource_group_name = azurerm_resource_group.this.name
}

resource "random_id" "this" {
  byte_length = 8
}

resource "azurerm_subnet" "a" {
  address_prefixes = [
    "10.0.1.0/24",
  ]
  name                                          = "subnet1"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_network_name                          = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "b" {
  address_prefixes = [
    "10.0.2.0/24",
  ]
  name                                          = "subnet2"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_network_name                          = azurerm_virtual_network.this.name
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]

  delegation {
    name = "Microsoft.Sql.managedInstances"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Sql/managedInstances"
    }
  }
}

resource "azurerm_subnet" "c" {
  address_prefixes = [
    "10.0.3.0/24",
  ]
  name                                          = "subnet3"
  enforce_private_link_service_network_policies = true
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_network_name                          = azurerm_virtual_network.this.name

  service_endpoints = [
    "Microsoft.AzureActiveDirectory",
  ]
}

# module.vnet.azurerm_subnet_network_security_group_association.vnet["subnet1"]:
resource "azurerm_subnet_network_security_group_association" "a" {
  network_security_group_id = azurerm_network_security_group.this.id
  subnet_id                 = azurerm_subnet.a.id
}

resource "azurerm_subnet_route_table_association" "a" {
  route_table_id = azurerm_route_table.this.id
  subnet_id      = azurerm_subnet.a.id
}

# module.vnet.azurerm_virtual_network.vnet:
resource "azurerm_virtual_network" "this" {
  address_space = [
    "10.0.0.0/16",
  ]
  location            = var.vnet_location
  name                = "acctvnet"
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    "costcenter"  = "it"
    "environment" = "dev"
  }
}
