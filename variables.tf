variable "region" {
  description = "La región de AWS"
  type        = string
  default     = "us-east-1"
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
  default     = "Change-Me-In-Production!"
  sensitive   = true
}
