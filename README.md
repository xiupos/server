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

curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale login # login to tailscale
sudo tailscale up --ssh

# # now you can connect to ssh with just the command
# ssh sapporo

sudo systemctl stop sshd
sudo systemctl disable sshd

sudo ufw enable # y
sudo ufw default allow

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades # <YES>
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
#-   //      "${distro_id}:${distro_codename}-updates";
#+           "${distro_id}:${distro_codename}-updates";

sudo apt-get install -y open-iscsi nfs-common
sudo systemctl enable --now iscsid
```

## For first machine in cluster

- https://docs.k0sproject.io/stable/k0s-multi-node/

```sh
curl --proto '=https' --tlsv1.2 -sSf https://get.k0s.sh | sudo sh

# first machine in cluster
sudo k0s install controller --enable-worker
sudo k0s start
sudo k0s kubectl taint node sapporo-2 node-role.kubernetes.io/control-plane-

# to control from local machine
sudo k0s kubeconfig admin > ~/config
vim ~/config
# rewrite "localhost" (in clusters[0].server) to tailscale ip address

# # local
# scp sapporo:config ~/.kube/k0s-config
```

## Add machines to cluster

```sh
# # sapporo
# sudo k0s token create --role=controller --expiry=12h > ~/token-file

# # local
# scp sapporo:token-file new-machine:token-file

# # new-machine
curl --proto '=https' --tlsv1.2 -sSf https://get.k0s.sh | sudo sh

sudo k0s install controller --enable-worker --token-file ~/token-file
sudo k0s start
sudo k0s kubectl taint node new-machine node-role.kubernetes.io/control-plane-
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
