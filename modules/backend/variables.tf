variable vpc_id {
  description = "ID de la VPC principal en la que se está montando la infraestructura"
  type = string
}

variable instance_sg_id {
  description = "ID del grupo de seguridad de las instancias del front"
  type = string
}

variable bastion_sg_id {
  description = "ID del grupo de seguridad del jump host o nodo bastion"
  type = string
}

variable private_id {
  description = "IDs de las subredes privadas creadas"
  type = list(string)
}

variable db_address {
  description = "Dirección de la base de datos RDS"
  type = string
}
