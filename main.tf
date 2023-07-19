# # main.tf

# # provider "aws" {
# #   region = "us-east-1"
# #   
# # }

# module "vpc" {
#   source = "./vpc"
#   vpc_cidr_block = "10.0.0.0/16"
# }

# module "subnets" {
#   source = "./vpc"
#   vpc_id = module.vpc.gameshop-vpc.id
#   subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
# }

# module "internet_gateway" {
#   source = "./vpc"
#   vpc_id = module.vpc.gameshop-vpc.id
# }

# module "nat_gateway" {
#   source = "./vpc"
#   vpc_id             = module.vpc.gameshop-vpc.id
#   subnet_id          = module.subnets.subnets[0].id
#   eip_allocation_id  = module.nat_gateway.gameshop-Nat-Gateway-EIP.id
# }

# module "route_table" {
#   source = "./vpc"
#   vpc_id = module.vpc.gameshop-vpc.id
#   subnet_id = module.subnets.subnets[0].id
# }
