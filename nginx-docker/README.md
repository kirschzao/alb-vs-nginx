# nginx-docker

Runs two instances of the sample app behind an Nginx reverse proxy, all on a shared Docker network (`lbnet`). Host port **8080** maps to Nginx port 80.

## Quickstart

```bash
# Start the stack (builds the app image from ../app)
docker compose up -d --build

# Hit the proxy a few times — served_by alternates between the two containers
curl localhost:8080
curl localhost:8080
curl localhost:8080

# Nginx internal health check (not forwarded to the app)
curl localhost:8080/nginx-health
```

## Config walkthrough

`nginx/default.conf` is adapted from the Oryza Labs production template. The key addition when scaling horizontally is the `upstream` block:

```nginx
upstream app_backend {
    server app1:3000 max_fails=3 fail_timeout=10s;
    server app2:3000 max_fails=3 fail_timeout=10s;
    keepalive 32;
}
```

Round-robin is the Nginx default; `least_conn` is preferred for workloads with uneven request durations. The `keepalive 32` directive keeps idle upstream connections open per worker, reducing per-request handshake overhead. All `proxy_set_header` directives and `client_max_body_size 100M` are kept exactly as they appear in the production template.

What was stripped for the local demo: the HTTP → HTTPS redirect block, `listen 443 ssl`, TLS directives, and the Certbot `/.well-known/acme-challenge` location. One deliberate improvement over the production template: the image is pinned to `nginx:1.27-alpine` instead of `nginx:latest` to prevent silent breaking changes on redeploy.

## Teardown

```bash
docker compose down
```
