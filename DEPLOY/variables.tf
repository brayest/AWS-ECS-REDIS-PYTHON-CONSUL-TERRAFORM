variable "ssh_pubkey_file" {}
variable "aws_profile" {}
data "aws_ecr_repository" "service" {
  name = "myapp"
}
