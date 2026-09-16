variable "environment" {
  description = "The environment name (e.g., staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "aws_load_balancer_controller_role_arn" {
  description = "IAM Role ARN for the AWS Load Balancer Controller Service Account"
  type        = string
}

variable "external_secrets_role_arn" {
  description = "IAM Role ARN for the External Secrets Operator Service Account"
  type        = string
}