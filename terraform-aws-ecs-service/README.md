# terraform-aws-ecs-service
Terraform module to create ECS service and tasks running multiple containers per instances with dynamic ports and surface via ALB

# Usage

be noted to have container_name same name as the name in the task definition like sample below `nginx-http` and port `80` otherwise you will get error container cannot be found. 
```hcl
module "ecs-service" {
  source = "anonymint/ecs-service/aws"

  service_name = "abc-service"
  ecs_cluster_id = "abc-cluster"
  container_definition = <<EOF
[
 {
   "name": "nginx-http",
   "image": "nginx",
   "cpu": 100,
   "memory": 256,
   "essential": true,
   "portMappings": [
     {
       "containerPort": 80,
       "hostPort": 0,
       "protocol": "tcp"
     }
   ]
 }
]
EOF
  container_name = "nginx-http"
  container_port = "80"
  vpc_id = "vpc-xxxxxxxx"
  security_groups = ["sg-xxxxxxxx"]
  subnet_ids = ["subnet-xxxxxxxx","subnet-xxxxxxxx"]
  ecs_service_role_arn = "arn:aws:iam::1111111111111:role/ecs-service-role"

}
```