#####
# ECS Service
#####

resource "aws_ecs_task_definition" "this" {
  family                = "${var.service_name}"
  container_definitions = "${var.container_definition}"
}

resource "aws_ecs_service" "this" {
  name            = "${var.service_name}"
  cluster         = "${var.ecs_cluster_id}"
  launch_type     = "EC2"
  task_definition = "${aws_ecs_task_definition.this.arn}"
  iam_role        = "${var.ecs_service_role_arn}"
  desired_count   = "${var.container_count}"

  load_balancer {
    elb_name          =  "${module.elb.this_elb_name}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }

  placement_constraints = "${var.placement_constraints}"

  placement_strategy = "${var.placement_strategies}"

  depends_on = ["module.elb", "aws_ecs_task_definition.this"]
}

#
# ELB
#

module "elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "${var.service_name}-alb"

  subnets         = ["${var.subnet_ids}"]
  security_groups = ["${var.security_groups}"]
  internal        = false

  listener = [
    {
      instance_port     = "${var.container_port}"
      instance_protocol = "HTTP"
      lb_port           = "${var.container_port}"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = [
    {
      target              = "HTTP:80/"
      interval            = 60
      healthy_threshold   = 10
      unhealthy_threshold = 10
      timeout             = 5
    },
  ]
}
