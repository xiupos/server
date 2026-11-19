# Grafana Alloy (Home Assistant local add-on)

Pushes Home Assistant metrics (`prometheus:` in `configuration.yaml`) to
monitor via Prometheus remote_write, so monitor needs no HA address or token.

Install: copy this directory to `/addons/alloy` (host: `/mnt/data/supervisor/apps/local/alloy`) on HA OS, then
Settings → Add-ons → Add-on store → ⋮ → Check for updates → Local add-ons → Grafana Alloy.
