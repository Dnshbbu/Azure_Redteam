## Organisation name 
variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "REDTEAM"
}

## Overall configs 
variable "resource_group" {
  description = "The name of your Azure Resource Group."
  default     = "REDTEAM_RG"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "northeurope"
}

## Virtual Networks 
variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "REDTEAM"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "The address prefix to use for the subnet."
  type = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}
variable "subnetname" {
  description = "The name to use for the subnet."
  type = list(string)
  default     = ["DMZ", "Internal"]
}

## NSG 
variable "source_network" {
  description = "Allow access from this network prefix. Defaults to '*'."
  default     = "*"
}

## Ubuntu Servers
variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B1s"
}

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "18.04-LTS"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}

## KaliLinux Servers
variable "kali_vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B1s"
}

variable "kali_image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "kali-linux"
}

variable "kali_image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "kali-linux"
}

variable "kali_image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "kali"
}

variable "kali_image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "2019.2.0"
}

variable "kali_plan_name" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "kali"
}

variable "kali_plan_product" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "kali-linux"
}

## DMZ servers 
variable "DMZMachines" {
  description = "C2 server and Guacamole server. Used for local hostname, DNS, and storage-related names."
  type = list(string)
  default     = ["guacserver","c2server"]
}

variable "DMZ_admin_username" {
  description = "Administrator user name"
}

variable "DMZ_admin_password" {
  description = "Administrator password"
}

## Internal Kali machines
variable "KaliMachines" {
  description = "Kali machines"
  type = list(string)
  default     = ["kali1","kali2"]
}

variable "kali_admin_username" {
  description = "Administrator user name"
}

variable "kali_admin_password" {
  description = "Administrator password"
}