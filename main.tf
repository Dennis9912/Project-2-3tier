provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source             = "./VPC"
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zone  = var.availability_zone
  public_cidr_block  = var.public_cidr_block
  private_cidr_block = var.private_cidr_block
  tags               = local.project_tags
}

module "alb" {
  source                 = "./ALB"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_az_1a_id = module.vpc.public_subnet_az_1a_id
  public_subnet_az_1b_id = module.vpc.public_subnet_az_1b_id
  ssl_policy             = var.ssl_policy
  acm_certificate_arn    = var.acm_certificate_arn
  tags                   = local.project_tags
}

module "asg" {
  source                 = "./ASG"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_az_1a_id = module.vpc.public_subnet_az_1a_id
  public_subnet_az_1b_id = module.vpc.public_subnet_az_1b_id
  alb_sg_id              = module.alb.alb_sg_id
  target_group_arn       = module.alb.target_group_arn
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  tags                   = local.project_tags
}