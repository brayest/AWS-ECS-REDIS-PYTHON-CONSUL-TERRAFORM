output "ELB_DNS_NAME" {
  value = "${aws_elb.myapp-elb.dns_name}"
}

output "CONSUL_PUBLIC_IP" {
  value = "${aws_instance.consul.public_ip}"
}