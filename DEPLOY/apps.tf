# - APPS - 
# Recreate the repository

resource "aws_elb" "myapp-elb" {
	name = "myapp-elb"
	security_groups	= ["${aws_security_group.myapp-elb-securitygroup.id}"]
	subnets			= ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]

	listener {
		instance_port		= 80
		instance_protocol 	= "http"
		lb_port 			= 80
		lb_protocol			= "http" 
	}

	health_check {
		healthy_threshold 	= 3
		unhealthy_threshold = 5
		timeout				= 5
		target 				= "HTTP:80/"
		interval			= 120
	}

  	cross_zone_load_balancing = false
  	idle_timeout = 60
  	connection_draining = true
  	connection_draining_timeout = 60

	tags {
		Name = "myapp-elb"
	}
}

data "template_file" "myapp-task-definition-template" {
	template = "${file("templates/app.json.tpl")}"

	vars {
		REPOSITORY_URL = "${replace("${data.aws_ecr_repository.service.repository_url}", "https://", "")}"
	}
}

resource "aws_ecs_task_definition" "myapp" {
	family 					= "myapp"
	container_definitions 	= "${data.template_file.myapp-task-definition-template.rendered}"
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
        "aws_autoscaling_group.ecs-example-autoscaling",
        "aws_elb.myapp-elb"
      ]
}

resource "aws_ecs_service" "myapp-service" {
	name 				= "myapp"
	cluster 			= "${aws_ecs_cluster.default.id}"
	launch_type			= "EC2"
	task_definition 	= "${aws_ecs_task_definition.myapp.arn}"
	desired_count		= 2
	iam_role 			= "${aws_iam_role.ecs-service-role.arn}"
	depends_on 			= ["aws_iam_role_policy.ecs_service_role_policy"]

	load_balancer {
		elb_name 		= "${aws_elb.myapp-elb.name}"
		container_name 	= "myapp"
		container_port 	= "80"
	}

	depends_on = [
        "aws_iam_role_policy.ecs_service",
        "aws_alb_listener.front_end",
        "aws_ecs_service.myapp-servce"
      ]
}

