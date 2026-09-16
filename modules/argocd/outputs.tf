output "argocd_release_status" {
  description = "Status of the ArgoCD Helm release"
  value       = helm_release.argocd.status
}

output "argocd_namespace" {
  description = "The namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}