FROM caddy:2-builder AS builder

RUN xcaddy build \
  --with github.com/caddyserver/certmagic@v0.15.4 \
  --with github.com/caddy-dns/cloudflare

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
