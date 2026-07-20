# Nginx or an AWS Load Balancer?

**Hands-on companion repo** for the article *"Nginx or an AWS Load Balancer? What Shipping 15+ Systems at a Software House Taught Me"* — every number in the article can be reproduced from this codebase.

📝 Companion article: coming soon on [AWS Builder Center](https://builder.aws.com/)

## What's in here

Three runnable stacks and a benchmark harness that make the trade-offs concrete:

```
alb-vs-nginx/
├── app/              # Node.js sample app — port 3000, /health, echoes its hostname
├── nginx-docker/     # docker-compose: 2 app replicas behind nginx (production-derived config)
├── terraform-alb/    # VPC + ALB + ECS Fargate (2 tasks) — the managed alternative
└── benchmark/        # k6-in-Docker load test: direct vs through-nginx proxy overhead
```

The Nginx config mirrors a real software-house production template (TLS blocks removed for the local demo), extended with the `upstream` block you add when one replica stops being enough — which is exactly the moment the ALB conversation starts.

## Quickstart

**1. Nginx load balancing, locally (under a minute):**

```bash
cd nginx-docker
docker compose up -d --build
curl -s localhost:8080   # run it a few times — watch served_by alternate between replicas
```

**2. Measure the proxy overhead (k6 via Docker, no install):**

```bash
cd benchmark
./run.sh                 # two 60s scenarios: direct vs through nginx
```

**3. The same app behind a real ALB (optional, needs an AWS account):**

```bash
cd terraform-alb
terraform init && terraform plan
# push app/ to your ECR first — see terraform-alb/README.md
```

> ⚠️ **Cost warning:** the Terraform stack costs ~$0.05/hour while running (us-east-1). **Run `terraform destroy` when you're done.**

## Sample results

Benchmark on a local Docker network (k6, 50 VUs, 60s, zero errors — this measures Nginx's proxy overhead, *not* ALB latency; methodology in the article):

| Scenario | req/s | p50 | p95 | p99 |
|---|---|---|---|---|
| Direct to app | 94,664 | 0.43 ms | 0.91 ms | 1.49 ms |
| Through Nginx | 58,781 | 0.67 ms | 1.86 ms | 2.91 ms |

Monthly cost of HA-equivalent setups (prices confirmed 2026-07-20 via the AWS Pricing API):

| Option (us-east-1) | 100 GB/mo | 1 TB/mo | 5 TB/mo |
|---|---|---|---|
| ALB (managed) | $17.23 | $24.43 | $56.42 |
| Nginx on 2x EC2 t3.small | $30.37 | $30.37 | $30.37 |
| Nginx on ECS Fargate, 2 tasks | $18.02 | $18.02 | $18.02 |

Yes: at low traffic, the managed ALB is *cheaper* than an HA pair of t3.smalls. That finding is what the article is about.

## Per-stack docs

| Stack | README |
|---|---|
| Nginx reverse proxy (local) | [nginx-docker/README.md](nginx-docker/README.md) |
| AWS ALB + ECS Fargate | [terraform-alb/README.md](terraform-alb/README.md) |
| Benchmark | [benchmark/README.md](benchmark/README.md) |

## Requirements

- **Docker** — for the Nginx stack and the benchmark
- **Terraform >= 1.5** — optional, only for the ALB stack
- **An AWS account** — only if you run `terraform apply`

## Author

**Bernardo Kirsch** — Cloud Solutions Architect & AWS Student Builder Group Leader (Rio Grande do Sul, Brazil)
[bekirsch.com](https://bekirsch.com) · [GitHub](https://github.com/kirschzao) · [LinkedIn](https://www.linkedin.com/in/bernardo-kirsch/)
