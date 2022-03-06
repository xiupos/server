#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

sudo systemctl disable --now backup-server.timer
sudo rm /etc/systemd/system/backup-server.service
sudo rm /etc/systemd/system/backup-server.timer
sudo systemctl daemon-reload
