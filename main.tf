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

module "route-53" {
  source       = "./ROUTE-53"
  zone_id      = var.zone_id
  domain_name  = var.domain_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "ec2" {
  source                 = "./EC2"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_az_1a_id = module.vpc.public_subnet_az_1a_id
  private_subnet_az_1a   = module.vpc.private_server_az_1a
  private_subnet_az_1b   = module.vpc.private_subnet_az_1b
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  tags                   = local.project_tags
}

module "rds" {
  source               = "./RDS"
  vpc_id               = module.vpc.vpc_id
  backend_subnet_az_1a = module.vpc.backend_subnet_az_1a
  backend_subnet_az_1b = module.vpc.backend_subnet_az_1b
  private_server_sg_id = module.ec2.private_server_sg_id
  allocated_storage    = var.allocated_storage
  instance_class       = var.instance_class
  engine_version       = var.engine_version
  parameter_group_name = var.parameter_group_name
  tags                 = local.project_tags
}