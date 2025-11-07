output "elb_dns" {
  value = module.frontend.elb_dns_name
  description = "Access your app at this ELB DNS"
}
