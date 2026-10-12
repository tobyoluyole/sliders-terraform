variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN assumed by the EBS CSI controller"
  type        = string
}

variable "ebs_csi_addon_version" {
  description = "Pinned EBS CSI add-on version compatible with the cluster"
  type        = string
}
