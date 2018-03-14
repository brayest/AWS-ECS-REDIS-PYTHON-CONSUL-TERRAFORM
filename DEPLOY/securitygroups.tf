# - Security Groups - 

resource "aws_security_group" "ecs-securitygroup" {
	name = "ecs-securitygroup"
	description = "ECS SG"
	vpc_id = "${aws_vpc.main.id}"

	#ALL
	ingress {
		from_port 	= 0
		to_port 	= 0
		protocol 	= "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

}

# Public
resource "aws_security_group" "myapp-elb-securitygroup" {
	name = "myapp-elb-securitygroup"
	description = "Load Balancer"
	vpc_id = "${aws_vpc.main.id}"

	#HTTP 
	ingress {
		from_port 	= 0
		to_port 	= 0
		protocol 	= "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port 	= 0
		to_port 	= 0
		protocol	= "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}
