output "ELB_DNS_NAME" {
  value = "${module.myapp-service.elb_url}"
}

output "CONSUL_PUBLIC_IP" {
  value = "${aws_instance.consul.public_ip}"
}
