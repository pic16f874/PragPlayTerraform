
region = "eu-central-1"

vpc_name = "test"
vpc_cidr = "10.1.0.0/16"

pub_subnets_def = [
  { az = "eu-central-1a", cidr = "10.1.8.0/24", nametag = "pub-a" },
  { az = "eu-central-1b", cidr = "10.1.9.0/24", nametag = "pub-b" },
  { az = "eu-central-1c", cidr = "10.1.10.0/24", nametag = "pub-c" }
]

#pub_snets_az      = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
#pub_snets_cidr    = ["10.1.8.0/24", "10.1.9.0/24", "10.1.10.0/24"]
#pub_snets_nametag = ["pub-a", "pub-b", "pub-c"]

nat_snet_a = "10.1.16.0/24"
nat_snet_b = "10.1.16.0/24"

loc_snet_a = "10.1.24.0/24"
loc_snet_b = "10.1.24.0/24"
