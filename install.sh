#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

sudo cp $DIR/backup-server.service /etc/systemd/system/backup-server.service
sudo cp $DIR/backup-server.timer /etc/systemd/system/backup-server.timer
sudo systemctl daemon-reload
sudo systemctl enable --now backup-server.timer
