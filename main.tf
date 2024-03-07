
# Create resource group
resource "azurerm_resource_group" "lms" {
  location = var.resource_group_location
  name     = "${var.service_name}-LMS"
  
}

# Create virtual network
resource "azurerm_virtual_network" "lms_terraform_network" {
  name                = "${var.service_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name
}

# Create subnet
resource "azurerm_subnet" "lms_terraform_subnet" {
  name                 = "${var.service_name}-subnet"
  resource_group_name  = azurerm_resource_group.lms.name
  virtual_network_name = azurerm_virtual_network.lms_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "lms_terraform_public_ip" {
  name                = "${var.service_name}-PublicIP"
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "lms_terraform_nsg" {
  name                = "${var.service_name}-NetworkSecurityGroup"
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name

  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 
}

# Create network interface
resource "azurerm_network_interface" "lms_terraform_nic" {
  name                = "${var.service_name}-myNIC"
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name

  ip_configuration {
    name                          = "${var.service_name}-nic-configuration"
    subnet_id                     = azurerm_subnet.lms_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lms_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "lms-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.lms_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.lms_terraform_nsg.id
}

# Creating (and displaying) an SSH key
resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# СCreating a virtual machine
resource "azurerm_linux_virtual_machine" "lms_terraform_vm" {
  name                  = "${var.service_name}-VM"
  location              = azurerm_resource_group.lms.location
  resource_group_name   = azurerm_resource_group.lms.name
  network_interface_ids = [azurerm_network_interface.lms_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.service_name}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "${var.service_name}-vm"
  admin_username                  = var.admin_username
  disable_password_authentication = false
  admin_password                  = var.admin_password

  
  
  provisioner "local-exec" {
    command = "sleep 100"  # A delay of 100 seconds
  }
  
  
  
  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/bwhite04/lms.git",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "mkdir -p ~/.docker/cli-plugins/",
      "curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose",
      "sudo chmod +x ~/.docker/cli-plugins/docker-compose",
      "sudo docker compose version",
      "cd lms/docker",
      "sudo docker compose up -d",



    ]
    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = azurerm_linux_virtual_machine.lms_terraform_vm.public_ip_address
    }               
  }
}
