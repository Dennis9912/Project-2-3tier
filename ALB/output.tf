output "alb_sg_id" {
  value = aws_security_group.dsa_alb_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.dsa_target_group.arn
}

output "alb_dns_name" {
  value = aws_lb.dsa_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.dsa_alb.zone_id
}
