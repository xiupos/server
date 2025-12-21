## Install

```bash
mkdir data
touch data/acme.json
chmod 600 data/acme.json

docker compose up -d
```

Token -> See https://github.com/libdns/cloudflare#readme

## Uninstall

```bash
docker compose down
```

## Update config files

```bash
git pull

docker compose up -d --force-recreate
# # or
# bash update.sh
```
