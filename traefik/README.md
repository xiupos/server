## Install

```bash
touch acme.json
chmod 600 acme.json

docker compose up -d
```

Token -> See https://github.com/libdns/cloudflare#readme


## Uninstall

```bash
docker compose down
```


## Update Caddyfile

```bash
vim Caddyfile

docker compose restart # && docker-compose logs -f
# # or
# bash update.sh
```
