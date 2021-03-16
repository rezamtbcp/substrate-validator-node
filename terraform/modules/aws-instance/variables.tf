variable instance_count {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable instance_type {
  description = "Type of EC2 instance to use"
  type        = string
}

variable subnet_ids {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable security_group_ids {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable project_name {
  description = "Name of the project"
  type        = string
}

variable environment {
  description = "Name of the environment"
  type        = string
}

variable ssh_key {
  description = "The SSH Public Key"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDiB3HFNwR/FglRXu7RbQ3C6bkgJJJKV9N5bm8yP1rBB2Ke2XD9L/Uok+SvixS1ly2kuvQE2hC6ZrWrmjkVEu7kKWP/9BoUE+V8TcY29pIJwlBXK92z/ZKf0r01wHg4dauqGnd6hGG3gkszl4TzF2eYV2kFHd8ZjVA1bqxvU3kXD9e1TzoRGsrMr4ZnmAAeSXzhV12cJTPsiXs2w5Wx1UoB2CWu7vz9cFjz51ui9JToR8/iC5ChwkwHuVZC/vUOmqFDOm9KmbHJkLGTQCGikw73qCmUKNAc/MBC6F12TIsy6+4zPpXox+sgOd0WGzukEnzwE2F2g6VM6XONZ+Rqa+rSMy4E6hayupVzgPpWrtme9RebPfhn0GmviuDNpIqJIjxoFqQO2J1OO5254fHs5m5vwjSWwp1Rc2qp45Uf4Jg8psZWZKHRO0nNyeMi1sW1/0gRwptYg+87Z3xfWXIUD9sWlzYXd8ShrDeTOxIIBQXOpHF4ACADkT54ATd4u1+Nk0E= reza@rezas-MacBook-Pro.local"
}

variable associate_public_ip {
  description = "Allow the instance(s) have public IP"
  type        = bool
  default     = true
}
