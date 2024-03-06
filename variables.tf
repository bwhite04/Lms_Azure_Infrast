variable "resource_group_location" {
  description = "Місце розташування ресурсної групи"
  type        = string
  default     = "UK South"  # Вкажіть своє бажане місце розташування за замовчуванням
}

variable "service_name" {
  description = "Назва сервісу"
  type        = string
  default     = "Frape-terraform"  # Вкажіть свою бажану назву сервісу за замовчуванням
}

variable "admin_username" {
  description = "Ім'я адміністратора для SSH"
  type        = string
  default = "secrets.AZURE_USER"   # Вкажіть своє бажане ім'я користувача за замовчуванням
}

variable "admin_password" {
  description = "Пароль адміністратора для SSH"
  type        = string
  default = "secrets.AZURE_PASS_USER" # Вкажіть свій бажаний пароль за замовчування
}
