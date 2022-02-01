variable "aws_region" {
  default = "us-east-1"
}

variable "cluster-name" {
  default = "preprod-cluster-dev"
  type    = string
}

variable "jenkin-user" {
  default = "ec2-user"
  type    = string
}