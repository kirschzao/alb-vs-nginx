# Nginx ou um Load Balancer da AWS?

**Repositório prático** que acompanha o artigo *"Nginx ou Load Balancer da AWS? O que aprendi entregando 15+ sistemas em Software House"* — todos os números do artigo podem ser reproduzidos a partir deste código.

📝 **Leia o artigo:** [Nginx ou Load Balancer da AWS? O que aprendi entregando 15+ sistemas em Software House](https://builder.aws.com/content/3Gm9On5fdYoVnRUCDQ3JtXNwRsy/nginx-ou-load-balancer-da-aws-o-que-aprendi-entregando-15-sistemas-em-software-house) — AWS Builder Center

## O que tem aqui

Três stacks executáveis e um harness de benchmark que tornam os trade-offs concretos:

```
alb-vs-nginx/
├── app/              # App de exemplo em Node.js — porta 3000, /health, responde com o hostname
├── nginx-docker/     # docker-compose: 2 réplicas da app atrás do nginx (config derivada de produção)
├── terraform-alb/    # VPC + ALB + ECS Fargate (2 tasks) — a alternativa gerenciada
└── benchmark/        # Teste de carga com k6 via Docker: direto vs através do nginx
```

A config do Nginx espelha um template real de produção de software house (blocos de TLS removidos para o demo local), estendida com o bloco `upstream` que você adiciona quando uma réplica só deixa de ser suficiente — exatamente o momento em que a conversa sobre o ALB começa.

## Início rápido

**1. Load balancing com Nginx, local (menos de um minuto):**

```bash
cd nginx-docker
docker compose up -d --build
curl -s localhost:8080   # rode algumas vezes — veja o served_by alternar entre as réplicas
```

**2. Meça o overhead do proxy (k6 via Docker, sem instalar nada):**

```bash
cd benchmark
./run.sh                 # dois cenários de 60s: direto vs através do nginx
```

**3. A mesma app atrás de um ALB de verdade (opcional, precisa de conta AWS):**

```bash
cd terraform-alb
terraform init && terraform plan
# suba a imagem de app/ para o seu ECR antes — veja terraform-alb/README.md
```

> ⚠️ **Aviso de custo:** a stack Terraform custa ~$0.05/hora enquanto estiver no ar (us-east-1). **Rode `terraform destroy` quando terminar.**

## Resultados de exemplo

Benchmark em rede Docker local (k6, 50 usuários virtuais, 60s, zero erros — mede o overhead de proxy do Nginx, *não* a latência do ALB; metodologia no artigo):

| Cenário | req/s | p50 | p95 | p99 |
|---|---|---|---|---|
| Direto na app | 94,664 | 0.43 ms | 0.91 ms | 1.49 ms |
| Através do Nginx | 58,781 | 0.67 ms | 1.86 ms | 2.91 ms |

Custo mensal de setups equivalentes em alta disponibilidade (preços confirmados em 2026-07-20 via AWS Pricing API):

| Opção (us-east-1) | 100 GB/mês | 1 TB/mês | 5 TB/mês |
|---|---|---|---|
| ALB (gerenciado) | $17.23 | $24.43 | $56.42 |
| Nginx em 2x EC2 t3.small | $30.37 | $30.37 | $30.37 |
| Nginx em ECS Fargate, 2 tasks | $18.02 | $18.02 | $18.02 |

Sim: com pouco tráfego, o ALB gerenciado sai *mais barato* que um par de t3.small em HA. Essa descoberta é o assunto do artigo.

## Documentação por stack

| Stack | README |
|---|---|
| Nginx reverse proxy (local) | [nginx-docker/README.md](nginx-docker/README.md) |
| AWS ALB + ECS Fargate | [terraform-alb/README.md](terraform-alb/README.md) |
| Benchmark | [benchmark/README.md](benchmark/README.md) |

## Requisitos

- **Docker** — para a stack do Nginx e o benchmark
- **Terraform >= 1.5** — opcional, só para a stack do ALB
- **Uma conta AWS** — só se você rodar `terraform apply`

## Autor

**Bernardo Kirsch** — Cloud Solutions Architect & AWS Student Builder Group Leader (Rio Grande do Sul, Brasil)
[bekirsch.com](https://bekirsch.com) · [GitHub](https://github.com/kirschzao) · [LinkedIn](https://www.linkedin.com/in/bernardo-kirsch/)
