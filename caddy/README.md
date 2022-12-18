## Install

```
docker-compose up -d
```

Token -> See https://github.com/libdns/cloudflare#readme


## Uninstall

```
docker-compose down
```


## Update Caddyfile

```
vim Caddyfile

docker-compose restart # && docker-compose logs -f
```
