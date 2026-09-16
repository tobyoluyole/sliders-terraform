variable "environment" {
  description = "The environment name (e.g., staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the EKS cluster OIDC Provider"
  type        = string
}