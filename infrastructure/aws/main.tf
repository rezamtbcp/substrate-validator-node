provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.iam_role_arn
    session_name = "TerraformBuilder"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  for_each = var.project

  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, each.value.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, each.value.public_subnet_count)

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

module "remote_access_security_group" {
  use_name_prefix = "false"
  source          = "terraform-aws-modules/security-group/aws//modules/ssh"
  version         = "3.17.0"

  for_each = var.project

  name        = "sg_remote_access_${each.key}_${each.value.environment}"
  description = "Security group for Accessing Validator Nodes in VPC"
  vpc_id      = module.vpc[each.key].vpc_id

  # we might only allow this via private subnets
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "traffic_security_group" {
  use_name_prefix = "false"
  source          = "terraform-aws-modules/security-group/aws"
  version         = "3.17.0"

  for_each = var.project

  name        = "sg_traffic_${each.key}_${each.value.environment}"
  description = "Security group for Validator Nodes Internet Traffic"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

