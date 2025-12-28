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
