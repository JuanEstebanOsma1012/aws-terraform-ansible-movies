output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "backend_private_ip" {
  value = aws_instance.back_end[*].private_ip
}

output "elb_back_dns_name" {
  value = aws_elb.back_elb.dns_name
}
