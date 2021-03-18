# Ubuntu Server 18.04 LTS (HVM) - ami-076a5bf4a712000ed
# http://www.ubuntu.com/cloud/services
# https://cloud-images.ubuntu.com/locator/
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20210224"]
  }
}

resource "aws_key_pair" "node" {
  public_key = var.ssh_key
}

resource "aws_instance" "node" {
  count = var.instance_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get dist-upgrade
    EOF

  key_name = aws_key_pair.node.key_name

  associate_public_ip_address = var.associate_public_ip

  tags = {
    Terraform   = "true"
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-${count.index}"
  }
}
