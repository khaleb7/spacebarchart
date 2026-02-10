# EKS + Spacebar Terraform Example

This example provisions an EKS cluster and installs Spacebar using the Helm chart.

**Chart location:** [GitHub](https://github.com/<owner>/spacebarchart) — chart path: `charts/spacebar` (replace `<owner>` with your org or username).

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- kubectl and helm (for verification)

## Usage

1. Copy and customize variables (e.g. `terraform.tfvars`):

   ```hcl
   aws_region     = "us-east-1"
   cluster_name   = "spacebar-eks"
   ingress_host   = "spacebar.example.com"
   s3_bucket      = "my-spacebar-cdn-bucket"

   ingress_tls = [{
     secretName = "spacebar-tls"
     hosts      = ["spacebar.example.com"]
   }]

   # Optional: create S3 bucket with Terraform (default: false = use existing bucket)
   # create_s3_bucket        = true
   # s3_bucket               = "my-spacebar-cdn-bucket"
   # s3_bucket_force_destroy = false
   ```

2. **S3 bucket:** Either create one yourself and set `s3_bucket` to its name, or let Terraform create it by setting `create_s3_bucket = true` and `s3_bucket = "my-spacebar-cdn-bucket"` in `terraform.tfvars`. When `create_s3_bucket` is true, Terraform creates the bucket (with block public access); you still need to grant the EKS node role or IRSA read/write to the bucket. The same bucket can be used for [Postgres backups](../../charts/spacebar/README.md#using-s3-for-postgres-backups-cloudnative-pg) (e.g. path prefix `s3://bucket/backups/postgres`).

3. Optionally create a Kubernetes secret with S3 credentials and JWT secrets, then set `spacebar_existing_secret` to its name.

4. Apply:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. Configure kubeconfig and verify:

   ```bash
   aws eks update-kubeconfig --region us-east-1 --name spacebar-eks
   kubectl get pods -n spacebar
   ```

## Ingress

Default Ingress class in the chart is `traefik`. To use Traefik on EKS, install it (e.g. via Helm) before or alongside this example. To use AWS ALB instead, set `ingress.className` to `alb` in the Helm values and install the AWS Load Balancer Controller.

## Terraform S3 options

| Variable | Default | Description |
|----------|---------|-------------|
| `s3_bucket` | (required) | S3 bucket name. When `create_s3_bucket` is true, this is the name of the bucket Terraform will create; otherwise an existing bucket. |
| `create_s3_bucket` | `false` | If true, Terraform creates an S3 bucket (with block public access). Use for CDN and optionally Postgres backups (same bucket, path prefix). |
| `s3_bucket_force_destroy` | `false` | When creating the bucket: allow destroy even if non-empty (use with caution). |

## Notes

- CloudNative-PG operator is installed in `cnpg-system`; Spacebar chart creates a Cluster CR in `spacebar` namespace.
- For production, use RDS or an external Postgres and set `database.externalUrl` (in a secret) and `database.enabled: true`, or keep the in-cluster CNPG Cluster.
