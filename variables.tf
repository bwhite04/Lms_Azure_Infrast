variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
  default     = "UK South"  
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "Frape-terraform"  
}

variable "admin_username" {
  description = "SSH administrator username"
  type        = string
  default = "secrets.AZURE_USER" 
}

variable "admin_password" {
  description = "SSH administrator password"
  type        = string
  default = "secrets.AZURE_PASS_USER" 
}
