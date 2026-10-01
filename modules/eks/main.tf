module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Cluster endpoint access
  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Enable OIDC Provider for IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  # Grant cluster admin permissions to the IAM user/role running Terraform
  enable_cluster_creator_admin_permissions = true

  # Default add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "${var.environment}-node-group"

      # Explicitly set AMI type to support EKS 1.30+
      ami_type       = "AL2023_x86_64_STANDARD"

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # Update strategy - max unavailable during upgrades
      update_config = {
        max_unavailable_percentage = 33
      }

      labels = {
        Environment = var.environment
        GithubRepo  = "sliders-gitops"
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}