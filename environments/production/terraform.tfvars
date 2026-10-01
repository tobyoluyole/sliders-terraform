environment     = "production"
cluster_name    = "sliders-production-cluster"
vpc_cidr        = "10.1.0.0/16"
azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

cluster_version = "1.30"
instance_types  = ["m5.large"]
min_size        = 3
max_size        = 10
desired_size    = 3