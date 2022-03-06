#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

sudo systemctl disable --now update-server.timer
sudo rm /etc/systemd/system/update-server.service
sudo rm /etc/systemd/system/update-server.timer
sudo systemctl daemon-reload
