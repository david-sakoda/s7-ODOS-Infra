resource "aws_vpc" "preprod" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = tomap({
    "Name"                                      = "terraform-eks-preprod-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.preprod.id

  tags = {
    Name = "terraform-eks-preprod"
  }
}

