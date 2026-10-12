data "aws_partition" "ebs_csi" {}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "${var.cluster_name}-ebs-csi-controller"

  role_policy_arns = {
    ebs_csi = "arn:${data.aws_partition.ebs_csi.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa"
      ]
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
