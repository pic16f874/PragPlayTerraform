provider "aws" {}

resource "aws_instance" "nginx" {
  #  ami = "ami-0a1ee2fb28fe05df3" #AmL2
  ami           = "ami-065deacbcaac64cf2" #Ubuntu 2204
  instance_type = "t3.micro"
#  user_data = file("user_data.sh")
#  vpc_security_group_ids = [aws_security_group.allow_http_s.id]

  tags = {
    Name    = "nginx1"
    Project = "test_task"
  }

}

/*
resource "aws_security_group" "allow_http_s" {
  name        = "allow_http_s"
  description = "Allow http and https inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_s"
  }
*/

}
