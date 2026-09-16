# ------------------------------------------------------------------------------
# AWS Load Balancer Controller IRSA
# ------------------------------------------------------------------------------
module "load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "${var.environment}-aws-load-balancer-controller"
  
  # Automatically attaches the official AWS IAM policy for the Load Balancer Controller
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      # Maps to the namespace and service account used by the ALBC Helm chart
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------------------------
# External Secrets Operator (ESO) IRSA
# ------------------------------------------------------------------------------
module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "${var.environment}-external-secrets-operator"
  
  # Automatically attaches permissions to read from AWS Secrets Manager
  attach_external_secrets_policy        = true
  # Scoped to all secrets in the account; can be restricted further if needed
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:eu-west-1:323708468663:secret:*"]

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      # Maps to the namespace and service account used by the ESO Helm chart
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}