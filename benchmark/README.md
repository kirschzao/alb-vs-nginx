# benchmark

k6 load test run entirely inside Docker — no local k6 install required. Uses the `lbnet` Docker network created by the `nginx-docker` stack to reach the containers directly.

## Prerequisites

The `nginx-docker` stack must be running:

```bash
cd ../nginx-docker && docker compose up -d --build
```

## Run

```bash
./run.sh
```

The script runs two back-to-back scenarios (50 VUs, 60 s each):

| Scenario | Target | What it measures |
|---|---|---|
| `direct` | `http://app1:3000` | Raw Node.js response time |
| `nginx` | `http://nginx:80` | Same path through the Nginx proxy |

The difference between the two gives you Nginx's proxying overhead on a local Docker network.

## Results

Raw JSON summaries are written to `benchmark-raw/direct.json` and `benchmark-raw/nginx.json` (one level above this folder in the standalone repo). Each file contains avg, median, p95, and p99 latency values produced by k6's `--summary-export` flag.

## Methodology disclaimer

> This is a **local benchmark on a Docker network**. It measures Nginx's proxying overhead, not ALB latency — an ALB benchmark would measure your network path to AWS more than the ALB itself. Use these numbers to reason about proxy cost in production, not to compare Nginx against ALB directly.
