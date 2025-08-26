terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

module "networking" {
  source               = "../../modules/networking"
  region               = var.region
  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "compute" {
  source = "../../modules/compute"

  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  web_sg_id          = module.networking.web_sg_id
  alb_sg_id          = module.networking.alb_sg_id
  name               = var.name
  ami_id             = var.ami_id
  tags               = var.tags

  depends_on = [module.networking]
}

