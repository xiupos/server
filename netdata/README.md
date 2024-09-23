## Install

```bash
docker compose up -d
sudo tailscale serve --bg localhost:19999
```

## Uninstall

```bash
docker compose down
sudo tailscale serve --https=443 off
```

## Update netdata

```bash
bash update.sh
```
