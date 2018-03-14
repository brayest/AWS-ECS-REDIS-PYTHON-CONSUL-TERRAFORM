# - ECS EC2 ROLE - 
resource "aws_iam_role" "ecs-ec2-role" {
	name = "ecs-ec2-role"
	assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_instance_profile" "ecs" {
	name = "ecs"
	path = "/"
	role = "${aws_iam_role.ecs-ec2-role.name}"
}


# -- Check consul -- 
resource "aws_iam_role" "ecs-consul-server-role" {
	name = "ecs-consul-server-role"
	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": [
          			"ecs.amazonaws.com",
          			"ec2.amazonaws.com"
        		]
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

resource "aws_iam_role_policy" "ecs-ec2-role-policy" {
	name = "ecs-ec2-role-policy"
	role = "${aws_iam_role.ecs-ec2-role.id}"
	policy = "${file("policies/ecs-instance-role-policy.json")}"
}


# -ECS service role - 
resource "aws_iam_role" "ecs-service-role" {
	name 				= "ecs-service-role"
	assume_role_policy 	= "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "ecs_service_role_policy"
    policy = "${file("policies/ecs-service-role-policy.json")}"
    role = "${aws_iam_role.ecs-service-role.id}"
}





















