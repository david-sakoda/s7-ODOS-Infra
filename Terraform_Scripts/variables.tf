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

variable "ssh-key-name" {
  default = "bootstrap-keypair"
  type    = string
}

variable "grafana-pass" {
  default = "graf@password"
  type    = string
}