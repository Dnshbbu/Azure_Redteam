# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  # version = "=2.0.0"
  version = "~> 2.15"
  features {}
}

# Resource group
resource "azurerm_resource_group" "tf_azure_guide" {
  name     = var.resource_group
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.tf_azure_guide.location
  address_space       = ["${var.address_space}"]
  resource_group_name = azurerm_resource_group.tf_azure_guide.name
}

# Subnet1: DMZ
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnetname[0]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.tf_azure_guide.name
  address_prefixes     = [var.subnets[0]]
}
# Subnet2: Internal
resource "azurerm_subnet" "subnet2" {
  name                 = var.subnetname[1]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.tf_azure_guide.name
  address_prefixes     = [var.subnets[1]]
}

# DMZ_SG - Allow inbound access on port 80 (http) and 22 (ssh)
resource "azurerm_network_security_group" "dmz_sg" {
  #name                = "${var.prefix}-sg"
  name                  = "${var.subnetname[0]}_SG"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name

  security_rule {
    name                       = "HTTP_80"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = var.subnets[0]
  }

  security_rule {
  name                       = "HTTP_8080"
  priority                   = 101
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8080"
  source_address_prefix      = "*"
  destination_address_prefix = var.subnets[0]
}

  security_rule {
    name                       = "SSH"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = var.subnets[0]
  }

  security_rule {
  name                       = "Internal_to_DMZ"
  priority                   = 103
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = var.subnets[1]
  destination_address_prefix = var.subnets[0]
}

}

# Internal_SG- Allow inbound access on port 80 (http) and 22 (ssh)
resource "azurerm_network_security_group" "internal_sg" {
  #name                = "${var.prefix}-sg"
  name                  = "${var.subnetname[1]}_SG"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name

  security_rule {
    name                       = "DMZ_to_Internal_SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnets[0]
    destination_address_prefix = var.subnets[1]
  }
}


resource "azurerm_subnet_network_security_group_association" "dmznsg" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.dmz_sg.id
}

resource "azurerm_subnet_network_security_group_association" "internalnsg" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.internal_sg.id
}

# Add Public IP to VM
resource "azurerm_public_ip" "pips" {
  count = length(var.DMZMachines)
  name                = "${var.DMZMachines[count.index]}-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.DMZMachines[count.index]
}


# NIC for DMZMachines
resource "azurerm_network_interface" "DMZnics" {
  count = length(var.DMZMachines)
  name                = "acctni-${var.DMZMachines[count.index]}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pips.*.id, count.index)
  }
}

# NIC for KaliMachines
resource "azurerm_network_interface" "KALInics" {
  count = length(var.KaliMachines)
  name                = "acctni-${var.KaliMachines[count.index]}"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = azurerm_subnet.subnet2.id # Need to hardcode the subnet ids to differentiate the subnets
    private_ip_address_allocation = "Dynamic"
  }
}

# Create C2 server and Guacamole server VMs
resource "azurerm_virtual_machine" "DMZVMs" {
  count = length(var.DMZMachines)
  name                = var.DMZMachines[count.index]
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name
  vm_size             = var.vm_size

  #network_interface_ids = [element(azurerm_network_interface.tf-guide-nic.*.id, count.index)]
  #network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
  network_interface_ids = [element(azurerm_network_interface.DMZnics.*.id, count.index)]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name              = "${var.DMZMachines[count.index]}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = var.DMZMachines[count.index]
    admin_username = var.DMZ_admin_username
    admin_password = var.DMZ_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # It's easy to transfer files or templates using Terraform.
  provisioner "file" {
    source      = "toupload/"
    destination = "/home/${var.DMZ_admin_username}"

    connection {
      type     = "ssh"
      user     = var.DMZ_admin_username
      password = var.DMZ_admin_password
      host     = element(azurerm_public_ip.pips.*.fqdn, count.index)
    }
  }
}

#   # This shell script starts our Apache server and prepares the demo environment.
#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/${var.DMZ_admin_username}/setup.sh",
#       "sudo /home/${var.DMZ_admin_username}/setup.sh",
#     ]

#     connection {
#       type     = "ssh"
#       user     = var.DMZ_admin_username
#       password = var.DMZ_admin_password
#       host     = element(azurerm_public_ip.pips.*.fqdn, count.index)
#     }
#   }
# }

# Create Kali VMs
resource "azurerm_virtual_machine" "KALIVMs" {
  #count = "${length(var.KaliMachines) == "1" ? 0 : 1} "
  count = 0
  name                = var.KaliMachines[count.index]
  location            = var.location
  resource_group_name = azurerm_resource_group.tf_azure_guide.name
  vm_size             = var.kali_vm_size

  #network_interface_ids = [element(azurerm_network_interface.tf-guide-nic.*.id, count.index)]
  #network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
  network_interface_ids = [element(azurerm_network_interface.KALInics.*.id, count.index)]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = var.kali_image_publisher
    offer     = var.kali_image_offer
    sku       = var.kali_image_sku
    version   = var.kali_image_version
  }

  storage_os_disk {
    name              = "${var.KaliMachines[count.index]}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = var.KaliMachines[count.index]
    admin_username = var.kali_admin_username
    admin_password = var.kali_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}