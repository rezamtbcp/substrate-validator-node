output instance_ids {
  description = "IDs of EC2 instances"
  value       = aws_instance.node.*.id
}

output instance_public_ips {
  description = "IP of EC2 instances"
  value       = aws_instance.node.*.public_ip
}
