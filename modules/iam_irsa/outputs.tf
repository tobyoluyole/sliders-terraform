output "aws_load_balancer_controller_role_arn" {
  description = "IAM Role ARN for the AWS Load Balancer Controller"
  value       = module.load_balancer_controller_irsa_role.iam_role_arn
}

output "external_secrets_role_arn" {
  description = "IAM Role ARN for the External Secrets Operator"
  value       = module.external_secrets_irsa_role.iam_role_arn
}