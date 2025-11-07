output "elb_dns_name" {
  value = aws_elb.web_elb.dns_name
}

output "instance_sg_id" {
  value = aws_security_group.instance_sg.id
}
