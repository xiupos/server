#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

sudo systemctl disable --now rclone-gdrive
sudo rm /etc/systemd/system/rclone-gdrive.service
sudo systemctl daemon-reload
sudo rm -rf /GDrive

sudo rm /usr/bin/rclone
sudo rm /usr/local/share/man/man1/rclone.1
