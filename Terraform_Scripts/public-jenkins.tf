# security group for internet access - for the public instance
resource "aws_security_group" "sg_allow_ssh_jenkins" {
  name        = "sg_allow_ssh_jenkins"
  vpc_id      = aws_vpc.preprod.id
  description = "Web Security Group - Allow SSH and Jenkins inbound traffic"

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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# public instance for jenkins
# need a user setup with a keypair download, rename to bootstrap-keypair.pem
resource "aws_instance" "web_facing_instance" {
  ami             = "ami-0a8b4cd432b1c3063"
  instance_type   = "t2.small"
  subnet_id       = aws_subnet.public-us-east-1a.id 
  vpc_security_group_ids = ["${aws_security_group.sg_allow_ssh_jenkins.id}"]
  key_name        = "bootstrap-keypair"   
  associate_public_ip_address = true    

  provisioner "remote-exec" {
    inline = [      
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",     
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo amazon-linux-extras install epel -y",
      "sudo amazon-linux-extras install java-openjdk11 -y",     
      "sudo yum install -y jenkins",      
      "sudo service jenkins start"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = var.jenkin-user
    private_key = file("bootstrap-keypair.pem")
  }

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}