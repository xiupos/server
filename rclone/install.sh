#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

curl https://rclone.org/install.sh | sudo bash

sudo mkdir /GDrive
sudo cp $DIR/rclone-gdrive.service /etc/systemd/system/rclone-gdrive.service
sudo systemctl daemon-reload
sudo systemctl enable --now rclone-gdrive
