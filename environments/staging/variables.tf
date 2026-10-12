variable "environment" { type = string }
variable "cluster_name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "instance_types" { type = list(string) }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_size" { type = number }
variable "cluster_version" { type = string }

variable "ebs_csi_addon_version" {
  description = "Pinned EBS CSI managed add-on version"
  type        = string
}
