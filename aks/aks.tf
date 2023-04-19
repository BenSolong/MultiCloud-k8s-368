resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = var.location
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "default-VN" {
  name                = "default-network"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "Public-subnet" {
  name                 = "Public-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default-VN.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_subnet" "PrivateSubnet-1" {
  name                 = "PrivateSubnet-1"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default-VN.name
  address_prefixes     = ["10.123.2.0/24"]
}

resource "azurerm_subnet" "PrivateSubnet-2" {
  name                 = "PrivateSubnet-2"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default-VN.name
  address_prefixes     = ["10.123.3.0/24"]
}

resource "azurerm_network_security_group" "default-sg" {
  name                = "default-sg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                              = "${random_pet.prefix.id}-aks"
  kubernetes_version                = var.kubernetes_version
  location                          = var.location
  resource_group_name               = azurerm_resource_group.default.name
  dns_prefix                        = "${random_pet.prefix.id}-k8s"
  role_based_access_control_enabled = true

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2]
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  tags = {
    environment = "Demo"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }
}


resource "azurerm_network_security_rule" "default-dev-rule" {
  name                        = "default-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.default-sg.name
}

resource "azurerm_subnet_network_security_group_association" "default-sga" {
  subnet_id                 = azurerm_subnet.Public-subnet.id
  network_security_group_id = azurerm_network_security_group.default-sg.id
}

resource "azurerm_public_ip" "default-Public-ip" {
  name                = "default-Public-ip"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_lb" "main" {
  name                = "main-lb"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.default-Public-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "main-backend-pool"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_lb_probe" "main" {
  name                = "main-probe"
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = "Http"
  request_path        = "/"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  name                           = "main-http-rule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.main.id
}

output "load_balancer_ip" {
  value = azurerm_public_ip.default-Public-ip.ip_address
}
