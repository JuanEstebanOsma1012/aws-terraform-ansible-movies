terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

#  backend "s3" {
#    bucket         = "mi-estado-terraform"
#    key            = "infraestructura/terraform.tfstate"
#    region         = "us-east-1"
#    encrypt        = true
#    dynamodb_table = "terraform-locks"
#  }
#}

provider "aws" {
  region  = var.region
}
