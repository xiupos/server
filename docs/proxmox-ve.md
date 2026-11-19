# Proxmox VE

## Install

```sh
# https://community-scripts.org/scripts/post-pve-install
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

## Tailscale

```sh
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh # login to tailscale

# Set ACL tags and disable key expiry
# https://login.tailscale.com/admin/machines

tailscale serve --bg https+insecure://localhost:8006
```

## Create new subnet

```sh
apt install -y dnsmasq
systemctl disable dnsmasq --now
```

Datacenter -> SDN -> Zones -> Add -> Simple:

- ID: `lanzone`
- Advanced [x]:
  - Automatic DHCP: [x]

Datacenter -> SDN -> Vnets -> Create:

- Name: `vnet1`
- Zone: `lanzone`

Datacenter -> SDN -> Vnets -> `vnet1` -> Subnets -> Create:

- General:
  - Subnet: `10.x.0.0/24`
  - Gateway: `10.x.0.1`
  - SNAT: [x]
- DHCP Ranges:
  - Add -> `10.x.0.100` ~ `10.x.0.200`

Datacenter -> SDN -> Apply.

```sh
# https://tailscale.com/docs/features/subnet-routers#connect-to-tailscale-as-a-subnet-router
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf

tailscale set --advertise-routes=10.x.0.0/24

# https://login.tailscale.com/admin/machines
# machine -> Edit route settings... -> Subnet routes -> [x] 10.x.0.0/24
```

## USB Bluetooth passthrough to a VM

Host `btusb` grabs Intel adapters while they re-enumerate during firmware load, so the VM never sees `hci0`. Keep it off the host.

```sh
lsusb | grep -i bluetooth  # e.g. 8087:0026

echo 'blacklist btusb' > /etc/modprobe.d/blacklist-btusb.conf
modprobe -r btusb

qm set <vmid> -usb0 host=8087:0026  # by ID, not port
qm reboot <vmid>
```

Check:

```sh
ls /sys/class/bluetooth              # host: empty, guest: hci0
echo 'info usb' | qm monitor <vmid>
```

Revert: `rm /etc/modprobe.d/blacklist-btusb.conf && modprobe btusb`.
