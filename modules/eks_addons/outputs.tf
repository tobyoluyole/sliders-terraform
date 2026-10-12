output "ebs_csi_addon_arn" {
  description = "ARN of the EBS CSI managed add-on"
  value       = aws_eks_addon.ebs_csi.arn
}

output "ebs_csi_addon_version" {
  description = "Configured EBS CSI managed add-on version"
  value       = aws_eks_addon.ebs_csi.addon_version
}
