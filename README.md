# Server

## Initialise Server

```sh
# # local
# ssh-keygen -R (server IP or hostname e.g. p-pleb-jp)
# ssh root@(worker hostname) # yes

# # root@(worker hostname) (if there is no non-root user)
# adduser xiupos
# gpasswd -a xiupos sudo
# sudo -iu xiupos

# # xiupos@(worker hostname)

echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh # login to tailscale

# # now you can connect to ssh with just the command
# ssh (worker hostname)
```

## Ansible

```sh
# jp
ansible-playbook -i ansible/inventory/hosts-jp.yml ansible/site.yml

# us
ansible-playbook -i ansible/inventory/hosts-us.yml ansible/site.yml

# eu
ansible-playbook -i ansible/inventory/hosts-eu.yml ansible/site.yml
```

## Set secrets

- edit `base/secrets/*-example.yml`

## Setup k3s cluster

```sh
# set jp as default
cp ~/.kube/config ~/.kube/config.old && cp ~/.kube/config-p-home-sapporo ~/.kube/config

# # jp
# functions --erase kubectl && alias kubectl="kubectl --kubeconfig ~/.kube/config-p-home-sapporo"

# # us
# functions --erase kubectl && alias kubectl="kubectl --kubeconfig ~/.kube/config-p-contabo-stlouis"

# # eu
# functions --erase kubectl && alias kubectl="kubectl --kubeconfig ~/.kube/config-p-contabo-nuremberg"
```

```sh
# common
kubectl apply -f base/infra/common/utils.yml

# Ingress (Traefik)
kubectl apply -f base/infra/net/traefik-config.yml

# Cloudflare Tunnel (shared)
kubectl apply -f base/secrets/cloudflare-tunnel-shared.yml
kubectl apply -f base/infra/net/cloudflare-tunnel-shared.yml

# # Cloudflare Tunnel (jp only)
# kubectl apply -f base/secrets/cloudflare-tunnel-jp.yml
# kubectl apply -f base/infra/net/cloudflare-tunnel-jp.yml

# Grafana Alloy
kubectl apply -f base/secrets/grafana-alloy.yml
kubectl apply -f base/infra/monitor/grafana-alloy.yml

# PostgreSQL Operator (CloudNativePG)
kubectl apply -f base/secrets/postgres-operator.yml
kubectl apply -f base/infra/db/postgres-operator.yml

# Misskey (mk-dev-k8s.xiupos.net; jp only)
kubectl apply -f base/app/misskey/mk-dev-k8s-xiupos-net.yml
```

```sh
# # unalias kubectl
# functions --erase kubectl
```
