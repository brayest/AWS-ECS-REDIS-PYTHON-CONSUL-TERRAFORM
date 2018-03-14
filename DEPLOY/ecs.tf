# Cluster

resource "aws_ecs_cluster" "default" {
	name = "default"
}

# -- Check for key pairs --
resource "aws_launch_configuration" "ecs-example-launchconfig" {
	name_prefix 			= "ecs-example-launchconfig"
	image_id 				= "${lookup(var.ECS_AMIS, var.AWS_REGION)}"
	instance_type			= "${var.ECS_INSTANCE_TYPE}"
	key_name 				= "${aws_key_pair.mykeypair.key_name}"
	iam_instance_profile 	= "${aws_iam_instance_profile.ecs.id}"
	security_groups 		= ["${aws_security_group.ecs-securitygroup.id}"]
	associate_public_ip_address = true
	user_data				= "${file("templates/ecs_init.sh")}"

	lifecycle {
    	create_before_destroy = true
  	}
}

resource "aws_autoscaling_group" "ecs-example-autoscaling" {
	name 					= "ecs-example-autoscaling"
	vpc_zone_identifier		= ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
	launch_configuration 	= "${aws_launch_configuration.ecs-example-launchconfig.name}"
	min_size				= 2
	max_size				= 4
	health_check_type 		= "EC2"

	tag {
		key 				= "Name"
		value				= "ecs-ec2-container"
		propagate_at_launch	= true
	}

	lifecycle {
    	create_before_destroy = true
  	}
}