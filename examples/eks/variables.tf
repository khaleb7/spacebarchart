variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "spacebar-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "ingress_host" {
  description = "Ingress host for Spacebar (e.g. spacebar.example.com)"
  type        = string
}

variable "ingress_tls" {
  description = "TLS config for Ingress (list of { secretName, hosts })"
  type        = list(any)
  default     = []
}

variable "s3_bucket" {
  description = "S3 bucket name for Spacebar CDN storage"
  type        = string
}

variable "spacebar_existing_secret" {
  description = "Existing Kubernetes secret name for Spacebar (DATABASE, S3, JWT, etc.)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for AWS resources"
  type        = map(string)
  default     = {}
}
