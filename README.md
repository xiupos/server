# Server

## Install

```bash
################################
# Initialize Server
################################

# # local
# ssh-keygen -R (server IP)
# ssh root@(server IP) # yes

## root@sapporo
adduser xiupos
gpasswd -a xiupos sudo
echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
sudo -iu xiupos

## xiupos@sapporo
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh # login to tailscale

# # now you can connect to ssh with just the command
# ssh sapporo

sudo systemctl stop sshd
sudo systemctl disable sshd

sudo ufw enable # y
sudo ufw default deny
sudo ufw limit 80/tcp comment http
sudo ufw limit 443/tcp comment https

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y unattended-upgrades debconf-utils
echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive unattended-upgrades
sudo sed -i 's|//\s*\("\${distro_id}:\${distro_codename}-updates";\)|\1|' /etc/apt/apt.conf.d/50unattended-upgrades

################################
# Install Docker
################################

sudo apt-get update
sudo apt-get install ca-certificates
sudo install -m 0755 -d /etc/apt/keyrings

# ubuntu
sudo snap install docker
sudo addgroup --system docker
sudo gpasswd -a $USER docker

# # debian
# sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# sudo gpasswd -a xiupos docker

sudo reboot

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
1. [Start Traefik](traefik/README.md)
1. Prepare backup files
1. `bash restore.sh`
