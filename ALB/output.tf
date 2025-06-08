output "alb_sg_id" {
  value = aws_security_group.dsa_alb_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.dsa_target_group.arn
}


