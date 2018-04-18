variable "service_name" {
  description = "The name of the service"
}

variable "ecs_cluster_id" {
  description = "ARN of an ECS cluster"
}

variable "ecs_service_role_arn" {
  description = " The ARN of IAM role that allows your Amazon ECS container agent to make calls to your load balancer on your behalf."
}

variable "container_definition" {
  description = "A list of valid container definitions provided as a single valid JSON document."
}

variable "placement_constraints" {
  type = "list"

  default = [
    {
      type = "distinctInstance"
    },
  ]
}

variable "placement_strategies" {
  type = "list"

  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
  ]
}

#####
# ELB related
#####
variable "vpc_id" {
  description = "The identifier of the VPC in which to create the ELB target group."
}

variable "security_groups" {
  type        = "list"
  description = "A list of security group IDs to assign to the ELB"
}

variable "subnet_ids" {
  type        = "list"
  description = "A list of subnet IDs to attach to the ELB, it has to be on different AZ at least"
}

variable "elb_port" {
  description = "Default exposed port of"
  default     = 80
}

#####
# Container related
#####

variable "container_name" {
  description = "The name of the container to associate with the load balancer (as it appears in a container definition)."
}

variable "container_port" {
  description = "The port on the container to associate with the load balancer."
}

variable "container_count" {
  description = "The number of task running"
  default     = 2
}
