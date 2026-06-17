# Server

```bash
just deploy-on [host name]
# or
nix run github:zhaofengli/colmena -- apply --on [host name]
```

## LXC

- Network: IPv4, IPv6 -> DHCP
- DNS Servers: `1.1.1.1`

Before launching

- Resources → Add → Device Passthrough: `/dev/net/tun` (for Tailscale)

`/etc/pve/lxc/[CT ID].conf` on Proxmox

```
lxc.apparmor.profile: unconfined
lxc.mount.entry: /dev/null sys/module/apparmor/parameters/enabled none bind 0 0
```

Login to LXC via SSH

```bash
passwd # set password

ln -sfn /nix/var/nix/profiles/system/init /sbin/init
ln -sfn /nix/var/nix/profiles/system/init /init
```

After first deploy

```bash
tailscale up --ssh
# Set ACL tags and disable key expiry
```

## Common

```bash
# create age key if need
mkdir -p /var/lib/sops-nix
age-keygen -o /var/lib/sops-nix/key.txt
# add pub key to .sops.yaml
```

## Restore

```bash
# Stop services w/o db
systemctl stop cloudflared
systemctl stop arion-misskey-mk-main
systemctl stop backup-misskey-mk-main-db-r2.timer
systemctl stop backup-misskey-mk-main-db-gdrive.timer

# List the backup
rclone --config /etc/rclone.conf \
  lsf gdrive:Backup/Servers/misskey-mk-main/db/ \
  --format "tp" \
  | sort

# Drop and Create DB
sudo -u postgres psql <<'EOF'
DROP DATABASE IF EXISTS "misskey-mk-main";
CREATE DATABASE "misskey-mk-main";
EOF

# Restore
rclone --config /etc/rclone.conf \
  cat gdrive:Backup/Servers/misskey-mk-main/db/dump.sql.gz \
| gunzip \
| sudo -u postgres psql \
    -d misskey-mk-main \
    -v ON_ERROR_STOP=1

# Check # of tables and notes
sudo -u postgres psql -d misskey-mk-main -c "\dt" | head -20
sudo -u postgres psql -d misskey-mk-main -c "SELECT COUNT(*) FROM \"note\";"

# Start misskey
systemctl start arion-misskey-mk-main

# Check misskey log
journalctl -u arion-misskey-mk-main -f

# Start Cloudflare Tunnel
# !!! DENGER !!!
systemctl staXt cloudflared

# Start Backup Timers
# !!! DENGER !!!
systemctl staXt backup-misskey-mk-main-db-r2.timer
systemctl staXt backup-misskey-mk-main-db-gdrive.timer
```
