# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.iam_role_arn
    session_name = "TerraformBuilder"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {
  state = "available"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
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

# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest/submodules/ssh
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

# https://github.com/terraform-aws-modules/terraform-aws-security-group
module "traffic_security_group" {
  use_name_prefix = "false"
  source          = "terraform-aws-modules/security-group/aws"
  version         = "3.17.0"

  for_each = var.project

  name        = "sg_traffic_${each.key}_${each.value.environment}"
  description = "Security group for Validator Nodes Traffic"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 30333
      to_port     = 30333
      protocol    = "tcp"
      description = "libp2p port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# Local Module
module "validator_nodes" {
  source = "./modules/aws-instance"

  for_each = var.project

  instance_count = each.value.instances
  instance_type  = each.value.instance_type
  subnet_ids     = module.vpc[each.key].public_subnets[*]
  security_group_ids = [
    module.traffic_security_group[each.key].this_security_group_id,
    module.remote_access_security_group[each.key].this_security_group_id,
  ]

  project_name = each.key
  environment  = each.value.environment
  public_key_path = var.public_key_path
}