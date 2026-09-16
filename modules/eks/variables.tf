variable "environment" {
  description = "The environment name (e.g., staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "The VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS nodes will be deployed (should be private subnets)"
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types for the EKS Managed Node Group"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of nodes in the Managed Node Group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the Managed Node Group"
  type        = number
}

variable "desired_size" {
  description = "Desired number of nodes in the Managed Node Group"
  type        = number
}