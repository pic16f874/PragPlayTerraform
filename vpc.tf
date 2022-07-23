#===== V P C  ==================================================================
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr
  tags       = { Name = var.vpc_name }
}
resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
  tags   = { Name = "${var.vpc_name}_igw" }
}

#---- s u b n e t s ------------------------------------------------------------
#resource "aws_subnet" "vpc1_pub_snets" { # set of public subnets
#  count             = length(var.pub_snets_az)
#  vpc_id            = aws_vpc.vpc1.id
#  availability_zone = var.pub_snets_az[count.index]
#  cidr_block        = var.pub_snets_cidr[count.index]
#  tags              = { Name = var.pub_snets_nametag[count.index] }
#}

resource "aws_subnet" "vpc1_pub_snets" { # set of public subnets
  count             = length(var.pub_subnets_def[*].az)
  vpc_id            = aws_vpc.vpc1.id
  availability_zone = var.pub_subnets_def[count.index].az
  cidr_block        = var.pub_subnets_def[count.index].cidr
  tags              = { Name = var.pub_subnets_def[count.index].nametag }
}

/*
resource "aws_subnet" "vpc1_nat_snet_a" { # NAT subnet
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.nat_snet_a
  availability_zone = "${var.region}a"
  tags              = { Name = "${var.vpc_name}-nat-a" }
}

resource "aws_subnet" "vpc1_loc_snet_a" { # local subnet
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.loc_snet_a
  availability_zone = "${var.region}a"
  tags              = { Name = "${var.vpc_name}-loc-a" }
}
*/

#===== Route tables and RT associations ========================================
#----- public networks ---------------------------------------------------------
resource "aws_route_table" "Pub_RT" { # route table for public subnet to igw
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }
  tags = { Name = "PubRT" }
}
resource "aws_route_table_association" "Pub_RT_a_snets" { # RT associations
  count          = length(aws_subnet.vpc1_pub_snets[*].id)
  subnet_id      = aws_subnet.vpc1_pub_snets[count.index].id
  route_table_id = aws_route_table.Pub_RT.id
}
/*
#----- NAT networks ------------------------------------------------------------
resource "aws_eip" "nat_eIP_a" { # elastic_ip for nat_gateway
  vpc  = true
  tags = { Name = "eIP_a" }
}
resource "aws_nat_gateway" "NATgw_a" { # nat_gateway
  allocation_id = aws_eip.nat_eIP_a.id
  subnet_id     = aws_subnet.vpc1_pub_snets[1].id
  tags          = { Name = "NATgw_a" }
}
resource "aws_route_table" "NAT_RT_a" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw_a.id
  }
  tags = { Name = "NAT_RT_a" }
}
resource "aws_route_table_association" "nat_RT_a_snets" {
  subnet_id      = aws_subnet.vpc1_nat_snet_a.id
  route_table_id = aws_route_table.NAT_RT_a.id
}
*/

#---- ALB ----------------------------------------------------
resource "aws_alb" "alb_nginx" {
  name = "alb-nginx"
  #  subnets         = [aws_subnet.vpc1_pub_snets[*].id]
  subnets         = [for subnet in aws_subnet.vpc1_pub_snets : subnet.id]
  security_groups = [aws_security_group.allow_http_s.id]
  internal        = false
  tags            = { Name = "alb-nginx" }
}

resource "aws_alb_target_group" "alb_nginx_tg" {
  name     = "alb-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 6
    path                = "/"
    port                = 80
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
