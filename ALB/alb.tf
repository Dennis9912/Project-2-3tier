#Configure Security group for Application Load Balancer
resource "aws_security_group" "dsa_alb_sg" {
  name        = "alb-sg"
  description = "Allow http and https inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
	Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.dsa_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.dsa_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.dsa_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Configure Target Group for Alb
resource "aws_lb_target_group" "dsa_target_group" {
  name        = "Target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"  # or "ip" or "lambda"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-Target-group"
  })
}

#Configure Application Load Balancer
resource "aws_lb" "dsa_alb" {
  name               = "Alb"
  internal           = false                                                            # Set to true for internal ALBs
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dsa_alb_sg.id]                                  # List of security group IDs
  subnets            = [var.public_subnet_az_1a_id, var.public_subnet_az_1b_id]         # List of public subnet IDs

  enable_deletion_protection = false                 # Optional: enables ALB deletion protection

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb"
  })
}

#Configure a listener on Port 80 with redirect action [HTTP]
resource "aws_lb_listener" "dsa_alb_http" {
  load_balancer_arn = aws_lb.dsa_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#Configure a listener on Port 443 with SSL certificate and default action [HTTPS]
resource "aws_lb_listener" "dsa_alb_https_listener" {
  load_balancer_arn = aws_lb.dsa_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn      # ACM certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dsa_target_group.arn
  }
}
