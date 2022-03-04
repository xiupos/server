## Install

```
cp example-docker.env docker.env
vim docker.env

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

docker-compose down
docker-compose up -d
```
