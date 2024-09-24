# Server for caddy

## Install

```bash
################################
# Initialize Server
################################

# # local
# ssh-keygen -R (server IP)
# ssh root@(server IP) # yes

## root@ishikari
adduser xiupos
gpasswd -a xiupos sudo
visudo
#-   %sudo   ALL=(ALL:ALL) ALL
#+   %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
sudo -iu xiupos

## xiupos@ishikari
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale login # login to tailscale
sudo tailscale up --ssh

# # now you can connect to ssh with just the command
# ssh ishikari

sudo systemctl stop sshd
sudo systemctl disable sshd

sudo ufw enable # y
sudo ufw default deny
sudo ufw limit 80/tcp comment http
sudo ufw limit 443/tcp comment https

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades # <YES>
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
#-   //      "${distro_id}:${distro_codename}-updates";
#+           "${distro_id}:${distro_codename}-updates";


################################
# Install Docker
################################

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

# ubuntu
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# # debian
# sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo gpasswd -a xiupos docker

################################
# Initialize
################################

docker network create external_network

sudo apt-get install -y git
git clone https://github.com/xiupos/server.git -b caddy

cp example-docker.env docker.env
vim docker.env
```

1. [Start Caddy](caddy/README.md)
1. [Start netdata](netdata/README.md)
1. `bash update-install.sh`
