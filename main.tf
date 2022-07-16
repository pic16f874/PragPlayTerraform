provider "aws" {}

resource "aws_key_pair" "boot_key" {
  key_name   = "H270-HD3-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsRH2fY5QibTnbwJ4G76EJMA6bWZxIJSXhjv5jzdSeDoq2gsMhI49NUWqkqEWAtCmjwxOe54nu7c7HaUMXgiNhsyrGWpGmnU+07d4xu2UG/bavKazLervr486P6ufiV232vYugeOjAfKxPBRMEUHZVmOHw9VJEEXEwR1xwzbnO2WfOgNYMptmMImIoA3L1sEw2s13GIsy546kzXHNPBzrxAWR3cC2xAJC/16QppbKcd+/dT1MR+o9oEeUXVv80aM+Tgg83woXs0c1oxQpDXSfV4l7lef7s7ORMC0DnNKSbINvTGvNrNoJtjHqC06KqYrNa5I3Cz2m6Nt8qHVFu33spRclSmsPIodCELwGvFUUnZ7xuCIP6AognVUw22TxQ/Y5P245vjjuhLgi60FhvghYhI5ddI5vOlXSGWJqvSlMBsleiGeOUgEeaECGqOc8Siti8kP5QBWtOGeKxwpKOmJuVfLlPsBd1Zr114EYNye13EgQzeE+PCLTpgMWogncs2Vpoj8yI4jGP39gXalcxM16eACGxprg3rK1lloKAbLgp289y7jagSvQ8YhAJapZT2D968euCsnOhUxeTebm/xC51i63k6XABGCW0olFjepsH48bCc6rfZmqVGKgzNBQVNEXXmI6EDJeRs2na1E6Eqo1TxJqWhtnL0aUmwXrSAaEx6Q== mykola-ivanov@mi-H270-HD3"
}

resource "aws_instance" "nginx" {
  #  ami = "ami-0a1ee2fb28fe05df3" #AmL2
  ami                    = "ami-065deacbcaac64cf2" #Ubuntu 2204
  instance_type          = "t3.micro"
  key_name               = "H270-HD3-key"
  user_data              = file("user_data.sh")
  vpc_security_group_ids = [aws_security_group.allow_http_s.id]

  tags = {
    Name    = "nginx1"
    Project = "test_task"
  }

}

resource "aws_security_group" "allow_http_s" {
  name        = "allow_http_s"
  description = "Allow http and https inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

}
