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

Edit `base/secrets/*-example.yml`.

## Setup k3s cluster

### Prepare kubeconfig

```sh
# set jp as default
cp ~/.kube/config ~/.kube/config.old && cp ~/.kube/config-p-home-sapporo ~/.kube/config

# # jp
# functions --erase kubectl && alias kubectl="kubectl --kubeconfig ~/.kube/config-p-home-sapporo"

# # us
# functions --erase kubectl && alias kubectl="kubectl --kubeconfig ~/.kube/config-p-contabo-stlouis"

# # eu
# functions --erase kubectl && alias kubectl="kubectl --kubeconfig ~/.kube/config-p-contabo-nuremberg"

# # unalias kubectl
# functions --erase kubectl
```

### Apply manifests

```sh
kubectl kustomize --load-restrictor LoadRestrictionsNone base/ | kubectl apply -f -
```

## (WIP) Start Apps

### Misskey (mk-dev.xiupos.net; jp only)

1. %%% DISABLE THE DOMAIN (mk-dev.xiupos.net) FROM [DASHBOARD](https://one.dash.cloudflare.com/) %%%
1. Prepare backup files in R2
1. Comment out half part of `base/app/misskey/mk-dev-xiupos-net.yml`
1. Start db:
    ```sh
    kubectl apply -f base/app/misskey/mk-dev-xiupos-net.yml
    ```
1. Edit `tools/postgres-db-restore.yml`
1. Restore db:
    ```sh
    kubectl apply -f tools/postgres-db-restore.yml
    ```
1. Uncomment 2.
1. Start misskey:
    ```sh
    kubectl apply -f base/app/misskey/mk-dev-xiupos-net.yml
    ```
1. Enable mk-dev.xiupos.net from [dashboard](https://one.dash.cloudflare.com/).

### Misskey (mk.xiupos.net; jp only)

1. %%% DISABLE THE DOMAIN (mk.xiupos.net) FROM [DASHBOARD](https://one.dash.cloudflare.com/) %%%
1. Prepare backup files in R2
1. Comment out half part of `base/app/misskey/mk-xiupos-net.yml`
1. Start db:
    ```sh
    kubectl apply -f base/app/misskey/mk-xiupos-net.yml
    ```
1. Edit `tools/postgres-db-restore.yml`
1. Restore db:
    ```sh
    kubectl apply -f tools/postgres-db-restore.yml
    ```
1. Uncomment 2.
1. Start misskey:
    ```sh
    kubectl apply -f base/app/misskey/mk-xiupos-net.yml
    ```
1. Enable mk.xiupos.net from [dashboard](https://one.dash.cloudflare.com/).
