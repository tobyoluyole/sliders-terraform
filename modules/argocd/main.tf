resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "6.7.11"

  values = [
    yamlencode({
      server = {
        extraArgs = ["--insecure"]
      }
      # Keeps resource usage low on initial boot
      dex      = { enabled = false }
      redis-ha = { enabled = false }
    })
  ]
}