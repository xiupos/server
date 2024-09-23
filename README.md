# Server for caddy

## Install

```bash
################################
# Initialize Server
################################

# # local
# ssh-keygen -R (server IP)
# ssh root@(the ip address) # yes

## root@tokyo
adduser xiupos
gpasswd -a xiupos sudo
visudo

-   %sudo   ALL=(ALL:ALL) ALL
+   %sudo   ALL=(ALL:ALL) NOPASSWD: ALL

sudo -iu xiupos

## xiupos@tokyo
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale login # login to tailscale
sudo tailscale up --ssh

# # now you can connect to ssh with just the command
# ssh tokyo

sudo systemctl stop sshd
sudo systemctl disable sshd

sudo ufw enable # y
sudo ufw default deny
sudo ufw limit (my port num)/tcp comment ssh
sudo ufw limit 80/tcp comment http
sudo ufw limit 443/tcp comment https

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades # <YES>
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
-   //      "${distro_id}:${distro_codename}-updates";
+           "${distro_id}:${distro_codename}-updates";


################################
# Install Docker
################################

curl -sSL https://get.docker.com/ | sh
sudo gpasswd -a ubuntu docker

sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# sudo reboot

################################
# Initialize
################################

docker network create external_network

sudo apt install -y git
git clone https://github.com/xiupos/server.git

cp example-docker.env docker.env
vim docker.env
```

1. [Start RCLONE](rclone/README.md)
1. [Start Caddy](caddy/README.md)
1. Prepare backup files
1. `bash restore.sh`
