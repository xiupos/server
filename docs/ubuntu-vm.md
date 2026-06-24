# Ubuntu server (VM)

```sh
echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers

curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh # login to tailscale

# login via tailscale

sudo systemctl disable ssh.socket sshd sshd --now

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y unattended-upgrades debconf-utils
echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive unattended-upgrades
sudo sed -i 's|//\s*\("\${distro_id}:\${distro_codename}-updates";\)|\1|' /etc/apt/apt.conf.d/50unattended-upgrades
```
