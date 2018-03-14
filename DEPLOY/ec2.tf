#  Consul Server
#
resource "aws_instance" "consul" {
  instance_type = "${var.CONSUL_INSTANCE_TYPE}"
  ami = "${var.CONSUL_AMI}"

  tags {
    Name = "Consul"
  }

  key_name = "${aws_key_pair.mykeypair.key_name}"
  vpc_security_group_ids =  ["${aws_security_group.ecs-securitygroup.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.ecs.id}"
  subnet_id = "${aws_subnet.main-public-1.id}"
  associate_public_ip_address = true
  user_data = "${file("templates/consul_init.sh")}"
  private_ip = "10.0.1.224"

}