#Configure Security group for Bastion-Host
resource "aws_security_group" "dsa_bastion_host_sg" {
  name        = "bastion-host-sg"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
	Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host-sg"
 })
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.dsa_bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
} 

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.dsa_bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Configure Bastion-Host
resource "aws_instance" "dsa_bastion_host" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_az_1a_id
  vpc_security_group_ids = [aws_security_group.dsa_bastion_host_sg.id]

  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["environment"]}-bastion"
  })
}

#Configure Security group for Private Servers
 resource "aws_security_group" "dsa_private_sg" {
  name        = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-sg"
  description = "Security group for private EC2 private servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dsa_bastion_host_sg.id]
  }

    egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-sg"
  })
}

#Configure Private server in az-1A
# resource "aws_instance" "dsa_private_server_az_1a" {
#   ami                    = var.image_id
#   instance_type          = var.instance_type
#   subnet_id              = var.private_subnet_az_1a
#   vpc_security_group_ids = [aws_security_group.dsa_private_sg.id]
#   key_name               = var.key_name

#   associate_public_ip_address = false  # Ensure instance remains private

#   tags = merge(var.tags, {
#     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-1a"
#   })
# }

#Configure Private server in az-1B
# resource "aws_instance" "dsa_private_server_az_1b" {
#   ami                    = var.image_id
#   instance_type          = var.instance_type
#   subnet_id              = var.private_subnet_az_1b
#   vpc_security_group_ids = [aws_security_group.dsa_private_sg.id]
#   key_name               = var.key_name

#   associate_public_ip_address = false  # Ensure instance remains private

#   tags = merge(var.tags, {
#     Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az-1b"
#   })
# }

#Configure Launch template for private servers
resource "aws_launch_template" "dsa_private_servers_lt" {
  name_prefix   = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-lt-"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.dsa_private_sg.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-lt"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-lt"
  })
}

#Configure Auto Scaling Group
resource "aws_autoscaling_group" "dsa_private_servers_asg" {
  name                      = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-asg"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [var.private_subnet_az_1a, var.private_subnet_az_1b]

  launch_template {
    id      = aws_launch_template.dsa_private_servers_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server"
    propagate_at_launch = true
  }
}
