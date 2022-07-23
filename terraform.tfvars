
region = "eu-central-1"

vpc_name = "test"
vpc_cidr = "10.1.0.0/16"

pub_subnets_def = [
  { az = "eu-central-1a", cidr = "10.1.8.0/24", nametag = "pub-a" },
  { az = "eu-central-1b", cidr = "10.1.9.0/24", nametag = "pub-b" },
  { az = "eu-central-1c", cidr = "10.1.10.0/24", nametag = "pub-c" }
]

nat_subnets_def = [
  { az = "eu-central-1a", cidr = "10.1.16.0/24", nametag = "nat-a" },
  { az = "eu-central-1b", cidr = "10.1.17.0/24", nametag = "nat-b" },
  { az = "eu-central-1c", cidr = "10.1.18.0/24", nametag = "nat-c" }
]

loc_subnets_def = [
  { az = "eu-central-1a", cidr = "10.1.24.0/24", nametag = "loc-a" },
  { az = "eu-central-1b", cidr = "10.1.25.0/24", nametag = "loc-b" },
  { az = "eu-central-1c", cidr = "10.1.26.0/24", nametag = "loc-c" }
]
