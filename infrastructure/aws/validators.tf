module "validator_nodes" {
  source = "modules/aws-instance"

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
}