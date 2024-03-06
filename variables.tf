variable "resource_group_location" {
  description = "Місце розташування ресурсної групи"
  type        = string
  default     = "UK South"  
}

variable "service_name" {
  description = "Назва сервісу"
  type        = string
  default     = "Frape-terraform"  
}

variable "admin_username" {
  description = "Ім'я адміністратора для SSH"
  type        = string
  default = "secrets.AZURE_USER" 
}

variable "admin_password" {
  description = "Пароль адміністратора для SSH"
  type        = string
  default = "secrets.AZURE_PASS_USER" 
}
