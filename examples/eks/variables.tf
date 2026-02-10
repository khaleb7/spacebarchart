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
  description = "S3 bucket name for Spacebar CDN storage. When create_s3_bucket is true, this is the name of the bucket to create; otherwise use an existing bucket name."
  type        = string
}

variable "create_s3_bucket" {
  description = "If true, create an S3 bucket for CDN (and optionally Postgres backups). If false, s3_bucket must be an existing bucket name."
  type        = bool
  default     = false
}

variable "s3_bucket_force_destroy" {
  description = "When create_s3_bucket is true: allow Terraform to destroy the bucket even if it has objects (use with caution)."
  type        = bool
  default     = false
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
