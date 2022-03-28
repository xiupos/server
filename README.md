# Server

## Install

```bash
################################
# Initialize Server
################################

# # local
# ssh-keygen -R (server IP)
# ssh root@stlouis -p 22 # yes

## root@stlouis
adduser ubuntu
gpasswd -a ubuntu sudo
visudo

-   %sudo   ALL=(ALL:ALL) ALL
+   %sudo   ALL=(ALL:ALL) NOPASSWD: ALL

sudo -iu ubuntu

## ubuntu@stlouis
mkdir .ssh && chmod 700 .ssh
touch .ssh/authorized_keys && chmod 600 .ssh/authorized_keys
cat <<EOF | tee .ssh/authorized_keys
(my pub keys)
EOF

sudo vim /etc/ssh/sshd_config
-   #Port 22
+   Port (my port num)
-   PermitRootLogin yes
+   PermitRootLogin no
-   #PubkeyAuthentication yes
+   PubkeyAuthentication no
-   #PasswordAuthentication yes
+   PasswordAuthentication no

sudo service sshd reload

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
```

1. [Start RCLONE](rclone/README.md)
1. [Start Caddy](caddy/README.md)
1. Prepare backup files
1. `bash restore.sh`
