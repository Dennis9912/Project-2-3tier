#Configure Simple routing policy
resource "aws_route53_record" "dsa_dns_record" {
  zone_id = var.zone_id                    # Hosted zone ID (must be created already)
  name    = var.domain_name                # e.g., "app.example.com"
  type    = "A"                            # Record type

  alias {
    name                   = var.alb_dns_name  # ALB DNS name
    zone_id                = var.alb_zone_id   # ALB hosted zone ID
    evaluate_target_health = true
  }
}