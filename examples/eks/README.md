# EKS + Spacebar Terraform Example

This example provisions an EKS cluster and installs Spacebar using the Helm chart.

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
   ```

2. Create an S3 bucket for CDN storage (or set `s3_bucket` to an existing bucket). Ensure the EKS node role or IRSA has read/write access.

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

## Notes

- CloudNative-PG operator is installed in `cnpg-system`; Spacebar chart creates a Cluster CR in `spacebar` namespace.
- For production, use RDS or an external Postgres and set `database.externalUrl` (in a secret) and `database.enabled: true`, or keep the in-cluster CNPG Cluster.
