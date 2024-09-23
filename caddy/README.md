## Install

```bash
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
