# Minimal EKS + Spacebar Helm chart example.
# Prerequisites: AWS credentials, kubectl, helm.
# Usage: terraform init && terraform apply

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  name   = var.cluster_name
  region = var.aws_region
  tags = merge(var.tags, {
    "terraform" = "true"
  })
}

# EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = var.kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = local.tags
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = local.tags
}

# Helm provider (uses EKS kubeconfig)
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# CloudNative-PG operator (required for in-cluster Postgres)
resource "helm_release" "cnpg" {
  namespace        = "cnpg-system"
  create_namespace  = true
  name             = "cnpg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = "0.21.0"
  wait             = true
  wait_for_jobs    = true
}

# Spacebar
resource "helm_release" "spacebar" {
  depends_on = [helm_release.cnpg]

  namespace       = "spacebar"
  create_namespace = true
  name            = "spacebar"
  chart           = "${path.module}/../../charts/spacebar"
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      ingress = {
        enabled    = true
        className  = "traefik"  # or "alb" / "nginx" if using those
        host       = var.ingress_host
        tls        = var.ingress_tls
      }
      storage = {
        provider = "s3"
        bucket   = var.s3_bucket
        region   = var.aws_region
      }
      database = {
        enabled = true
      }
      postgresql = {
        installOperator = false  # we install CNPG above
        cluster = {
          instances = 1
          storage  = { size = "1Gi" }
        }
      }
      existingSecret = var.spacebar_existing_secret  # optional: secret with S3 creds, JWT, etc.
    })
  ]
}
