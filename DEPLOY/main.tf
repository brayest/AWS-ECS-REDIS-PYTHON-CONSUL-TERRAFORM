
provider "aws" {
  region = "us-east-1"
  profile = "${var.aws_profile}"
}

#
# SSH Access key
#
resource "aws_key_pair" "app_key" {
  key_name   = "app_key"
  public_key = "${var.ssh_pubkey_file}"
}

#
# Base VPC Creation
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "modules-example"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  tags = {
    Owner       = "brayest"
    Environment = "dev"
  }
}

#
# POLICIES
#
module "ecs-ec2" {
  source                        = "anonymint/iam-role/aws"
  role_name                     = "ecs-ec2"
  policy_arns_count             = "1"
  policy_arns                   = ["${aws_iam_policy.ecs-ec2-policy.arn}"]
  create_instance_role          = true
  iam_role_policy_document_json = "${file("policies/ecs-role.json")}"
}

module "ecs-service" {
  source                        = "anonymint/iam-role/aws"
  role_name                     = "ecs-service"
  policy_arns_count             = "1"
  policy_arns                   = ["${aws_iam_policy.ecs-service-policy.arn}"]
  create_instance_role          = true
  iam_role_policy_document_json = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_policy" "ecs-ec2-policy" {
    name = "ecs-ec2-role-policy"
    path = "/custom/"
    policy = "${file("policies/ecs-instance-role-policy.json")}"
}

resource "aws_iam_policy" "ecs-service-policy" {
    name = "ecs-service-policy"
    path = "/custom/"
    policy = "${file("policies/ecs-service-role-policy.json")}"
}

resource "aws_iam_instance_profile" "ecs" {
        name = "ecs"
        path = "/"
        role = "${module.ecs-ec2.this_iam_role_name}"
}

#
# Basic Security Groups
#

# BASIC SG
resource "aws_security_group" "ecs-securitygroup" {
        name = "ecs-securitygroup"
        description = "ECS SG"
        vpc_id = "${module.vpc.vpc_id}"

        #ALL
        ingress {
                from_port       = 0
                to_port         = 0
                protocol        = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

}

# ELB SG
resource "aws_security_group" "myapp-elb-securitygroup" {
        name = "myapp-elb-securitygroup"
        description = "Load Balancer"
        vpc_id = "${module.vpc.vpc_id}"

        #HTTP
        ingress {
                from_port       = 0
                to_port         = 0
                protocol        = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port       = 0
                to_port         = 0
                protocol        = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

#
# CONSUL SERVER
#

resource "aws_instance" "consul" {
  instance_type = "t2.micro"
  ami = "ami-5eaf8124"

  tags {
    Name = "Consul"
  }

  key_name = "${aws_key_pair.app_key.key_name}"
  vpc_security_group_ids =  ["${aws_security_group.ecs-securitygroup.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.ecs.id}"
  subnet_id = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("templates/consul_init.sh")}"
  private_ip = "10.0.1.224"

}


#
# AUTOSCALING
#
module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "modules-myapp"

  # Launch configuration
  lc_name = "myapp-lc"

  image_id              = "ami-cad827b7"
  instance_type         = "t2.micro"
  security_groups       = ["${aws_security_group.ecs-securitygroup.id}"]
  key_name              = "${aws_key_pair.app_key.key_name}"
  user_data             = "${file("templates/ecs_init.sh")}"
  iam_instance_profile  = "${aws_iam_instance_profile.ecs.id}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "myapp-asg"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]
}

#
#  CLUSTER
#
resource "aws_ecs_cluster" "default" {
        name = "default"
}

data "template_file" "myapp-task" {
        template = "${file("templates/app.json.tpl")}"

        vars {
                REPOSITORY_URL = "${replace("${data.aws_ecr_repository.service.repository_url}", "https://", "")}"
        }
}

resource "aws_ecs_task_definition" "redis" {
  family = "redis"
  container_definitions = "${file("templates/redis.json.tpl")}"
}

resource "aws_ecs_service" "redis" {
  name = "redis-server"
  cluster = "${aws_ecs_cluster.default.id}"
  task_definition = "${aws_ecs_task_definition.redis.arn}"
  desired_count = "1"

  depends_on = [
      "aws_instance.consul",
      "module.autoscaling",
      "module.myapp-service"

    ]

}

module "myapp-service" {
  source = "./terraform-aws-ecs-service"

  service_name = "myapp-service"
  ecs_cluster_id = "${aws_ecs_cluster.default.id}"
  container_definition = "${data.template_file.myapp-task.rendered}"
  container_name = "myapp"
  container_port = "80"
  vpc_id = "${module.vpc.vpc_id}"
  security_groups = ["${aws_security_group.myapp-elb-securitygroup.id}"]
  subnet_ids = ["${module.vpc.public_subnets}"]
  ecs_service_role_arn = "${module.ecs-service.this_iam_role_arn}"

}
