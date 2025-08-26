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

module "database" {
  source = "../../modules/database"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  db_sg_id           = module.networking.db_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  name               = var.name

  tags = var.tags
}
