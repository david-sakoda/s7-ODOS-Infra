resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.preprod.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name                               = "private-us-east-1b"
    "kubernetes.io/role/internal-elb"  = "1"
    "kubernetes.io/cluster/preprod-cluster-dev"       = "shared"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.preprod.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  

  tags = {
    Name                               = "private-us-east-1a"
    "kubernetes.io/role/internal-elb"  = "1"
    "kubernetes.io/cluster/preprod-cluster-dev"       = "shared"
  }
}


resource "aws_subnet" "public-us-east-1a" {
  vpc_id            = aws_vpc.preprod.id
  cidr_block        = "10.0.64.0/19"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                               = "public-us-east-1a"
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/preprod-cluster-dev"       = "shared"
  }
}


resource "aws_subnet" "public-us-east-1b" {
  vpc_id            = aws_vpc.preprod.id
  cidr_block        = "10.0.96.0/19"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                               = "public-us-east-1b"
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/preprod-cluster-dev"       = "shared"
  }
}



# security group for internet access - for the public instance
resource "aws_security_group" "public_sg_with_aurora" {
  name        = "public_sg_with_aurora"
  vpc_id      = aws_vpc.preprod.id
  description = "Web Security Group - Allow Public and Aurora Instance inbound traffic"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/19", "10.0.32.0/19"]
  }  

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/19", "10.0.32.0/19"]
  }    

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.preprod.id
  subnet_ids = [        
        aws_subnet.private-us-east-1a.id,
        aws_subnet.private-us-east-1b.id
    ]
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.64.0/19" 
    from_port  = 0
    to_port    = 0  
  }

   ingress {
    protocol   = -1
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.96.0/19" 
    from_port  = 0
    to_port    = 0 
  }

  tags = {
    Name = "private-nacl"
  }
}