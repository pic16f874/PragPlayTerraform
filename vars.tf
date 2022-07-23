variable "region" { description = "AWS region name" }

variable "vpc_name" { description = "vps name like prod or test" }
variable "vpc_cidr" { description = "vps cidr block" }

variable "pub_subnets_def" {
  description = "This var defines public subnets block"
  type = list(object({
    az      = string
    cidr    = string
    nametag = string
  }))
}
variable "nat_subnets_def" {
  description = "This var defines public subnets block"
  type        = list(object({ az = string, cidr = string, nametag = string }))
}
variable "loc_subnets_def" {
  description = "This var defines public subnets block"
  type        = list(object({ az = string, cidr = string, nametag = string }))
}
