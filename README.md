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
visudo
#-   %sudo   ALL=(ALL:ALL) ALL
#+   %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
sudo -iu xiupos

## xiupos@sapporo
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


################################
# Install Docker
################################

sudo snap install docker
sudo gpasswd -a xiupos docker

# sudo reboot

################################
# Initialize
################################

sudo apt install -y git
git clone https://github.com/xiupos/server.git

cp example-docker.env docker.env
vim docker.env
```

1. [Start RCLONE](rclone/README.md)
1. Prepare backup files
1. `bash restore.sh`
