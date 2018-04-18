output ecs_service_name {
  description = "ECS Service name"
  value       = "${aws_ecs_service.this.name}"
}

output ecs_task_definition {
  description = "ECS Task ARN"
  value       = "${aws_ecs_task_definition.this.arn}"
}

output "elb_url" {
  value = "${module.elb.this_elb_dns_name}"
}
