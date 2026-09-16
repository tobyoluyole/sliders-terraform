module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Enable NAT Gateway for private subnets (required for EKS nodes to reach the internet)
  enable_nat_gateway     = true
  single_nat_gateway     = true # Cost optimization: uses 1 NAT GW per env instead of 1 per AZ
  one_nat_gateway_per_az = false

  # Required for EKS to resolve AWS service endpoints
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Subnet Tagging Rules for AWS Load Balancer Controller
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}