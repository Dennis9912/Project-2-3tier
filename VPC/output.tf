output "vpc_id" {
  value = aws_vpc.dsa_vpc.id
}

output "public_subnet_az_1a_id" {
  value = aws_subnet.dsa_public_subnet_az_1a.id
}

output "public_subnet_az_1b_id" {
  value = aws_subnet.dsa_public_subnet_az_1b.id
}

output "private_server_az_1a" {
  value = aws_subnet.dsa_private_subnet_az_1a.id
}

output "private_subnet_az_1b" {
  value = aws_subnet.dsa_private_subnet_az_1b.id
} 

output "backend_subnet_az_1a" {
  value = aws_subnet.dsa_backend_subnet_az_1a.id
}

output "backend_subnet_az_1b" {
  value = aws_subnet.dsa_backend_subnet_az_1b.id
}