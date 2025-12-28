# Server for Reverse Proxy

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
echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
sudo -iu xiupos

## xiupos@ishikari
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh # login to tailscale

# # now you can connect to ssh with just the command
# ssh ishikari

sudo systemctl stop sshd
sudo systemctl disable sshd

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y ufw
sudo ufw enable # y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0
sudo ufw limit 80/tcp comment http
sudo ufw limit 443/tcp comment https

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

# # ubuntu
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc
# sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
# Types: deb
# URIs: https://download.docker.com/linux/ubuntu
# Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
# Components: stable
# Signed-By: /etc/apt/keyrings/docker.asc
# EOF

# debian
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo addgroup --system docker
sudo gpasswd -a $USER docker

sudo reboot

################################
# Initialize
################################

docker network create external_network

sudo apt-get install -y git
git clone https://github.com/xiupos/server.git -b reverse-proxy
cd server

cp example-docker.env docker.env
vim docker.env # edit constants
```

1. [Start Traefik](traefik/README.md)
1. `bash update-install.sh`
