# ------------------------------------------------------------------------------
# Providers Configuration
# ------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ------------------------------------------------------------------------------
# Core Infrastructure Modules
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  environment     = var.environment
  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  source = "../../modules/eks"

  environment     = var.environment
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_types  = var.instance_types
  min_size        = var.min_size
  max_size        = var.max_size
  desired_size    = var.desired_size
  cluster_version = var.cluster_version
}

module "iam_irsa" {
  source = "../../modules/iam_irsa"

  environment       = var.environment
  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
}

# ------------------------------------------------------------------------------
# Bootstrap Modules (Helm + GitOps)
# ------------------------------------------------------------------------------
module "helm_bootstraps" {
  source = "../../modules/helm_bootstraps"

  environment                           = var.environment
  cluster_name                          = var.cluster_name
  aws_load_balancer_controller_role_arn = module.iam_irsa.aws_load_balancer_controller_role_arn
  external_secrets_role_arn             = module.iam_irsa.external_secrets_role_arn

  depends_on = [module.eks]
}

module "argocd" {
  source = "../../modules/argocd"

  environment = var.environment

  depends_on = [module.helm_bootstraps]
}

module "eks_addons" {
  source = "../../modules/eks_addons"

  environment           = var.environment
  cluster_name          = module.eks.cluster_name
  ebs_csi_role_arn      = module.iam_irsa.ebs_csi_role_arn
  ebs_csi_addon_version = var.ebs_csi_addon_version

  # Wait for the cluster, node groups, IAM role, and policy attachments.
  depends_on = [
    module.eks,
    module.iam_irsa,
  ]
}
