variable "AWS_REGION" {
	default = "us-east-1"
}

data "aws_ecr_repository" "service" {
  name = "myapp"
}

variable "ECS_INSTANCE_TYPE" {
	default = "t2.micro"
}

variable "CONSUL_INSTANCE_TYPE" {
	default = "t2.micro"
}

variable "ECS_AMIS" {
	type = "map"
	default = {
		us-east-1 = "ami-cad827b7"
	}
}

variable "CONSUL_AMI" {
	default = "ami-5eaf8124"
}

