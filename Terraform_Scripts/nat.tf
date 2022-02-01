resource "aws_eip" "custom-eip" {
    vpc = true
    
    tags = {
        Name =  "custom-eip"
    }
}

resource "aws_nat_gateway" "custom-nat" {
    allocation_id = aws_eip.custom-eip.id
    subnet_id     = aws_subnet.public-us-east-1a.id

    tags = {
        Name = "custom-nat"
    }

    depends_on = [aws_internet_gateway.igw]
}