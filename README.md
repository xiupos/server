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
ansible-playbook -i ansible/hosts.yml ansible/site.yml
```

## K3s

```sh
# # xiupos@(server hostname)
sudo cat /etc/rancher/k3s/k3s.yaml > config
sed -i "s/127.0.0.1/$HOSTNAME/" config

# # local
# cp ~/.kube/config ~/.kube/config.old
# scp (server hostname):config ~/.kube/config

# now you can use `kubectl` from local
```

### Set secrets

```sh
cp k8s/example-secrets.yml k8s/secrets.yml
# edit secrets.yml
```

### Cloudflare Tunnel

```sh
kubectl create ns cloudflare
kubectl apply -f secrets.yml
kubectl apply -f base/infrastructure/networking/cloudflare.yml
```

### Ingress (Traefik)

```sh
kubectl apply -f secrets.yml
kubectl apply -f base/infrastructure/networking/traefik-config.yml
```
