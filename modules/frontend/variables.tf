variable vpc_id {
  description = "ID de la VPC principal en la que se está montando la infraestructura"
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

variable backend_private_ip {
  description = "IPs privadas de las instancias del backend"
  type = list(string)
}

variable public_id {
  description = "IDs de las subredes publicas creadas"
  type = list(string)
}

variable elb_back_dns_name {
  description = "Registro DNS para el elb del backend"
  type = string
}
