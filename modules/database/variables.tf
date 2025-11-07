variable vpc_id {
  description = "ID de la VPC principal en la que se está montando la infraestructura"
  type = string
}

variable backend_sg_id {
  description = "ID del grupo de seguridad del backend"
  type = string
}

variable private_id {
  description = "Lista de los ids de las redes privadas creadas"
  type = list(string)
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "applicationuser"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  default     = "applicationuser"
  sensitive   = true
}
