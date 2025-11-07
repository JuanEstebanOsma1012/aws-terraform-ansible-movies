variable "vpc_id" {
  description = "ID de la VPC principal en la que se está montando la infraestructura"
  type = string
}

variable "public_id_1" {
  description = "ID de la segunda subred publica creada, subred en la que va ubicado el bastion"
  type = string
}
