terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region  = var.region
}

module "provider" {
  source = "./modules/provider"
}

module "backend" {
  source = "./modules/backend"
  vpc_id = module.network.vpc_id
  instance_sg_id = module.frontend.instance_sg_id
  bastion_sg_id = module.bastion.bastion_sg_id
  private_id = module.network.private_id
  db_address = module.database.db_address
}

module "frontend" {
  source = "./modules/frontend"
  vpc_id = module.network.vpc_id
  bastion_sg_id = module.bastion.bastion_sg_id
  private_id = module.network.private_id
  backend_private_ip = module.backend.backend_private_ip
  public_id = module.network.public_id  
  elb_back_dns_name = module.backend.elb_back_dns_name
}

module "network" {
  source = "./modules/network"
}

module "bastion" {
  source = "./modules/bastion"
  vpc_id = module.network.vpc_id
  public_id_1 = module.network.public_id_1
}

module "database" {
  source = "./modules/database"
  vpc_id = module.network.vpc_id
  backend_sg_id = module.backend.backend_sg_id
  private_id = module.network.private_id
  db_username = var.db_username
  db_password = var.db_password
}
