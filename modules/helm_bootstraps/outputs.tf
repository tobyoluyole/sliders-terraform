output "albc_release_status" {
  description = "Status of the AWS Load Balancer Controller Helm release"
  value       = helm_release.aws_load_balancer_controller.status
}

output "eso_release_status" {
  description = "Status of the External Secrets Operator Helm release"
  value       = helm_release.external_secrets.status
}