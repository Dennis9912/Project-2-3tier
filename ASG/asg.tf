#Configure Security group for frontend Servers
resource "aws_security_group" "dsa_frontend_server_sg" {
  name        = "frontend-server-sg"
  description = "Allow ssh, http and https inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
	Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend-server-sg"
	})
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.dsa_frontend_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
} 

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.dsa_frontend_server_sg.id
  referenced_security_group_id = var.alb_sg_id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.dsa_frontend_server_sg.id
  referenced_security_group_id = var.alb_sg_id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.dsa_frontend_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Configure Launch template for frontend servers
resource "aws_launch_template" "dsa_frontend_lt" {
  name_prefix   = "frontend-template"
  image_id      = var.image_id                      # Amazon Machine Image ID
  instance_type = var.instance_type                # e.g., t2.micro
  key_name      = var.key_name                     # Optional: SSH key name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.dsa_frontend_server_sg.id]
  }

  user_data = base64encode(file("Scripts/frontend-server.sh"))  # Bootstrap script

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend-template"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Configure Auto Scaling Group
resource "aws_autoscaling_group" "frontend_asg" {
  name                      = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-asg"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  vpc_zone_identifier       = [var.public_subnet_az_1a_id, var.public_subnet_az_1b_id]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.dsa_frontend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  termination_policies = ["OldestInstance", "Default"]
}

