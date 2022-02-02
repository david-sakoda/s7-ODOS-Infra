resource "aws_instance" "bastion" {
  ami             = "ami-0a8b4cd432b1c3063"
  instance_type   = "t2.small"
  subnet_id       = aws_subnet.public-us-east-1a.id  
  key_name        = "bootstrap-keypair" 
  security_groups             = ["${aws_security_group.bastion-sgroup.id}"]
  associate_public_ip_address = true

}

resource "aws_security_group" "bastion-sgroup" {
  name   = "bastion-sg"
  vpc_id      = aws_vpc.preprod.id  

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}