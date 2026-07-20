# terraform-alb

Provisions a VPC, an Application Load Balancer, and an ECS Fargate service with **2 tasks** running the sample app. `terraform plan` and `terraform validate` work without AWS credentials. An actual `apply` requires an AWS account.

**Estimated cost while running: ~$0.05/hour in us-east-1** (ALB $0.0225/h + 2 Fargate tasks at 0.25 vCPU / 512 MB ≈ $0.0245/h), plus a few dollars per TB of LCU traffic. **Run `terraform destroy` when you are done.**

## Prerequisites

### 1. AWS credentials

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1   # or your preferred region
```

### 2. Build and push the app image to ECR

The default `var.app_image` value (`111111111111.dkr.ecr...`) is a **non-working placeholder**. Replace it with a real image before `apply`.

```bash
# Create the repository (one-time)
aws ecr create-repository --repository-name sample-app --region us-east-1

# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com"

# Build, tag, and push (run from the repo root)
docker build -t sample-app ./app
docker tag sample-app:latest \
  "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/sample-app:latest"
docker push \
  "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/sample-app:latest"
```

> Change `us-east-1` to your target region in every command above if you override `var.region`.

## Usage

```bash
terraform init
terraform plan -var app_image=<your-ecr-image-uri>
terraform apply -var app_image=<your-ecr-image-uri>
```

After `apply`, Terraform prints `alb_dns_name`. Hit it a few times to see round-robin across the two Fargate tasks:

```bash
curl http://<alb_dns_name>
curl http://<alb_dns_name>
```

## Teardown

```bash
terraform destroy -var app_image=<your-ecr-image-uri>
```

## What gets created

| Resource | Detail |
|---|---|
| VPC | 10.0.0.0/16, 2 public subnets across 2 AZs |
| ALB | Internet-facing, port 80, security group open to 0.0.0.0/0 |
| Target group | IP-based, health check on `/health` |
| ECS Fargate service | 2 tasks, 0.25 vCPU / 512 MB each, public IP (no NAT Gateway) |
| CloudWatch log group | `/ecs/alb-vs-nginx`, 7-day retention |
