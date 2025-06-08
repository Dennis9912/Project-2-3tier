output "vpc_id" {
  value = aws_vpc.dsa_vpc.id
}

output "public_subnet_az_1a_id" {
  value = aws_subnet.dsa_public_subnet_az_1a.id
}

output "public_subnet_az_1b_id" {
  value = aws_subnet.dsa_public_subnet_az_1b.id
}