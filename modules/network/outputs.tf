output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_id_1" {
  value = aws_subnet.public[1].id
}

output "private_id" {
  value = aws_subnet.private[*].id
}

output "public_id" {
  value = aws_subnet.public[*].id
}
