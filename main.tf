provider "aws" {}

#---- SSH keys  ----------------------------------------------------------------
resource "aws_key_pair" "boot_key" {
  key_name   = "H270-HD3-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsRH2fY5QibTnbwJ4G76EJMA6bWZxIJSXhjv5jzdSeDoq2gsMhI49NUWqkqEWAtCmjwxOe54nu7c7HaUMXgiNhsyrGWpGmnU+07d4xu2UG/bavKazLervr486P6ufiV232vYugeOjAfKxPBRMEUHZVmOHw9VJEEXEwR1xwzbnO2WfOgNYMptmMImIoA3L1sEw2s13GIsy546kzXHNPBzrxAWR3cC2xAJC/16QppbKcd+/dT1MR+o9oEeUXVv80aM+Tgg83woXs0c1oxQpDXSfV4l7lef7s7ORMC0DnNKSbINvTGvNrNoJtjHqC06KqYrNa5I3Cz2m6Nt8qHVFu33spRclSmsPIodCELwGvFUUnZ7xuCIP6AognVUw22TxQ/Y5P245vjjuhLgi60FhvghYhI5ddI5vOlXSGWJqvSlMBsleiGeOUgEeaECGqOc8Siti8kP5QBWtOGeKxwpKOmJuVfLlPsBd1Zr114EYNye13EgQzeE+PCLTpgMWogncs2Vpoj8yI4jGP39gXalcxM16eACGxprg3rK1lloKAbLgp289y7jagSvQ8YhAJapZT2D968euCsnOhUxeTebm/xC51i63k6XABGCW0olFjepsH48bCc6rfZmqVGKgzNBQVNEXXmI6EDJeRs2na1E6Eqo1TxJqWhtnL0aUmwXrSAaEx6Q== mykola-ivanov@mi-H270-HD3"
}


#===== V P C  ==================================================================
resource "aws_vpc" "stage_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "stage-vpc" }
}

resource "aws_internet_gateway" "stage_igw" {
  vpc_id = aws_vpc.stage_vpc.id
  tags   = { Name = "stage-igw" }

}
#---- s u b n e t s ------------------------------------------------------------
resource "aws_subnet" "stage_pub_subnet_a" {
  vpc_id            = aws_vpc.stage_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-central-1a"
  tags              = { Name = "stage-pub-1a" }
}
resource "aws_subnet" "stage_pub_subnet_b" {
  vpc_id            = aws_vpc.stage_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-central-1b"
  tags              = { Name = "stage-pub-1b" }
}

resource "aws_subnet" "stage_prv_subnet_a" {
  vpc_id            = aws_vpc.stage_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "eu-central-1a"
  tags              = { Name = "stage-prv-1a" }
}
resource "aws_subnet" "stage_prv_subnet_b" {
  vpc_id            = aws_vpc.stage_vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "eu-central-1b"
  tags              = { Name = "stage-prv-1b" }
}

#---- Route tables -------------------------------------------------------------
resource "aws_route_table" "Pub_RT" {
  vpc_id = aws_vpc.stage_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stage_igw.id
  }
  tags = { Name = "Pub-RT" }

}
resource "aws_route_table" "Prv_RT" {
  vpc_id = aws_vpc.stage_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw_a.id
  }
  tags = { Name = "Prv-RT" }
}


#---- Route tables association -------------------------------------------------
resource "aws_route_table_association" "Pub_RT_association" {
  subnet_id      = aws_subnet.stage_pub_subnet_a.id
  route_table_id = aws_route_table.Pub_RT.id
}
resource "aws_route_table_association" "Prv_RT_association" {
  subnet_id      = aws_subnet.stage_prv_subnet_a.id
  route_table_id = aws_route_table.Prv_RT.id
}

resource "aws_eip" "nat_eIP_a" {
  #---- Elastic IP and NAT GW ----------------------------------------------------
  vpc = true
}
resource "aws_nat_gateway" "NATgw_a" {
  allocation_id = aws_eip.nat_eIP_a.id
  subnet_id     = aws_subnet.stage_pub_subnet_a.id
}


#---- ALB ----------------------------------------------------
resource "aws_alb" "alb_nginx" {
  name            = "alb-nginx"
  subnets         = [aws_subnet.stage_pub_subnet_a.id, aws_subnet.stage_pub_subnet_b.id]
  security_groups = [aws_security_group.allow_http_s.id]
  internal        = false
  tags = {
    Name = "alb-nginx"
  }
  #  access_logs {
  #    bucket = "${var.s3_bucket}"
  #    prefix = "ELB-logs"
  #  }
}

resource "aws_alb_target_group" "alb_nginx_tg" {
  name     = "alb-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.stage_vpc.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/login"
    port = 80
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb_nginx.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.alb_nginx_tg.arn
    type             = "forward"
  }
}

#Instance Attachment
resource "aws_alb_target_group_attachment" "svc_physical_external" {
  target_group_arn = "aws_alb_target_group.alb_nginx_tg.arn"
  target_id        = aws_instance.nginx_1.id
  port             = 80
}

/*
resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = ["aws_alb_target_group.alb_target_group"]
  listener_arn = "${aws_alb_listener.alb_listener.arn}"
  priority     = "${var.priority}"
  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
  }
  condition {
    field  = "path-pattern"
    values = ["${var.alb_path}"]
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "${var.target_group_name}"
  port     = "${var.svc_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  tags {
    name = "${var.target_group_name}"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = "${var.target_group_sticky}"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "${var.target_group_path}"
    port                = "${var.target_group_port}"
  }
}

#Instance Attachment
resource "aws_alb_target_group_attachment" "svc_physical_external" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.svc.id}"
  port             = 8080
}

*/



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


#===== Instances ===============================================================
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
  vpc_id      = aws_vpc.stage_vpc.id

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

output "instance_id_1" { value = aws_instance.nginx_1.id }
output "instance_ip_1" { value = aws_instance.nginx_1.public_ip }

#output "instance_id_2" { value = aws_instance.nginx_2.id }
#output "instance_ip_2" { value = aws_instance.nginx_2.public_ip }
