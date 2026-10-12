terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_addon_version
  service_account_role_arn = var.ebs_csi_role_arn

  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
