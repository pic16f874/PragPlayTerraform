#---- SSH keys  ----------------------------------------------------------------
resource "aws_key_pair" "boot_key" {
  key_name   = "H270-HD3-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsRH2fY5QibTnbwJ4G76EJMA6bWZxIJSXhjv5jzdSeDoq2gsMhI49NUWqkqEWAtCmjwxOe54nu7c7HaUMXgiNhsyrGWpGmnU+07d4xu2UG/bavKazLervr486P6ufiV232vYugeOjAfKxPBRMEUHZVmOHw9VJEEXEwR1xwzbnO2WfOgNYMptmMImIoA3L1sEw2s13GIsy546kzXHNPBzrxAWR3cC2xAJC/16QppbKcd+/dT1MR+o9oEeUXVv80aM+Tgg83woXs0c1oxQpDXSfV4l7lef7s7ORMC0DnNKSbINvTGvNrNoJtjHqC06KqYrNa5I3Cz2m6Nt8qHVFu33spRclSmsPIodCELwGvFUUnZ7xuCIP6AognVUw22TxQ/Y5P245vjjuhLgi60FhvghYhI5ddI5vOlXSGWJqvSlMBsleiGeOUgEeaECGqOc8Siti8kP5QBWtOGeKxwpKOmJuVfLlPsBd1Zr114EYNye13EgQzeE+PCLTpgMWogncs2Vpoj8yI4jGP39gXalcxM16eACGxprg3rK1lloKAbLgp289y7jagSvQ8YhAJapZT2D968euCsnOhUxeTebm/xC51i63k6XABGCW0olFjepsH48bCc6rfZmqVGKgzNBQVNEXXmI6EDJeRs2na1E6Eqo1TxJqWhtnL0aUmwXrSAaEx6Q== mykola-ivanov@mi-H270-HD3"
}




/*
#Instance Attachment
resource "aws_alb_target_group_attachment" "nginx_1" {
  target_group_arn = "aws_alb_target_group.alb_nginx_tg.arn"
  target_id        = aws_instance.nginx_1.id
  port             = 80
}
*/



/*
#---- i n t e r f a c e s ------------------------------------------------------
resource "aws_network_interface" "if1_z1a" {

  subnet_id   = aws_subnet.stage_pub_subnet_a.id
  private_ips = ["10.0.10.10"]
  tags        = { Name = "if1-z1a" }
}

#resource "aws_network_interface" "if1_z1b" {
#  subnet_id   = aws_subnet.stage_subnet_b.id
#  private_ips = ["10.0.11.10"]
#  tags        = { Name = "if1-z1b" }
#}
*/

#===== Instances ===============================================================
/*
resource "aws_instance" "nginx_1" {
  #  ami = "ami-0a1ee2fb28fe05df3" #AmL2
  ami           = "ami-065deacbcaac64cf2" #Ubuntu 2204
  instance_type = "t3.micro"
  key_name      = "H270-HD3-key"
  user_data     = file("user_data.sh")
  network_interface {
    network_interface_id = aws_network_interface.if1_z1a.id
    device_index         = 0
  }
  #  vpc_security_group_ids = [aws_security_group.allow_http_s.id, aws_security_group.allow_ssh.id]
  tags = { Name = "nginx1", Project = "test_task" }
}
resource "aws_network_interface" "if1_z1a" {
  subnet_id = aws_subnet.vpc1_pub_snets[1].id
  #  private_ips = ["10.0.10.10"]
  tags = { Name = "if1-z1a" }
}
*/




/*
resource "aws_instance" "nginx_2" {
  #  ami = "ami-0a1ee2fb28fe05df3" #AmL2
  ami           = "ami-065deacbcaac64cf2" #Ubuntu 2204
  instance_type = "t3.micro"
  key_name      = "H270-HD3-key"
  user_data     = file("user_data.sh")
  network_interface {
    network_interface_id = aws_network_interface.if1_z1b.id
    device_index         = 0
  }
  #vpc_security_group_ids = [aws_security_group.allow_http_s.id, aws_security_group.allow_ssh.id]
  tags = { Name = "nginx2", Project = "test_task" }
}
*/

#===== SecGroups ===============================================================
resource "aws_security_group" "allow_http_s" {
  name        = "allow_http_s"
  description = "Allow http and https inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

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

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow_ssh"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_ssh"
  }
}

#output "instance_id_1" { value = aws_instance.nginx_1.id }
#output "instance_ip_1" { value = aws_instance.nginx_1.public_ip }

#output "instance_id_2" { value = aws_instance.nginx_2.id }
#output "instance_ip_2" { value = aws_instance.nginx_2.public_ip }
