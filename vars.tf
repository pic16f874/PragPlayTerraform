variable "region" { description = "AWS region name" }

variable "vpc_name" { description = "vps name like prod or test" }
variable "vpc_cidr" { description = "vps cidr block" }

variable "pub_subnets_def" {
  description = "This var defines public subnets block"
  type = list(object({
    az   = string
    cidr = string
  nametag = string }))
}

#variable "pub_snets_az" {}
#variable "pub_snets_cidr" {}
#variable "pub_snets_nametag" {}

variable "nat_snet_a" {}
variable "nat_snet_b" {}

variable "loc_snet_a" {}
variable "loc_snet_b" {}
