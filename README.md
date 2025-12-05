# Server

## Initialize Server

```sh
# # local
# ssh-keygen -R (server IP or hostname)
# ssh root@(server IP or hostname) # yes

# # root@sapporo (if there is no non-root user)
# adduser xiupos
# gpasswd -a xiupos sudo
# sudo -iu xiupos

# # xiupos@sapporo

sudo EDITOR=vi visudo
#-   %sudo   ALL=(ALL:ALL) ALL
#+   %sudo   ALL=(ALL:ALL) NOPASSWD: ALL

curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale login # login to tailscale
sudo tailscale up --ssh

# # now you can connect to ssh with just the command
# ssh sapporo

sudo systemctl stop ssh ssh.socket
sudo systemctl disable ssh

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable # y

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades # <YES>
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
#-   //      "${distro_id}:${distro_codename}-updates";
#+           "${distro_id}:${distro_codename}-updates";

sudo swapoff -a
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# reboot

sudo apt-get install -y open-iscsi nfs-common
sudo systemctl enable --now iscsid
```

## Ingress

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  -f 01-ingress/ingress-values.yaml \
  -n ingress-nginx \
  --create-namespace
```

## Longhorn

- https://longhorn.io/docs/1.10.1/deploy/install/install-with-helm/

```sh
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --create-namespace \
  --set persistence.defaultClass=true \
  --set defaultSettings.defaultReplicaCount=2
```

## CloudNativePG

- https://cloudnative-pg.io/charts/

```sh
helm repo add cnpg https://cloudnative-pg.io/charts
helm repo update
helm install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace
```
