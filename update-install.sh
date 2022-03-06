#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

sudo cp $DIR/update-server.service /etc/systemd/system/update-server.service
sudo cp $DIR/update-server.timer /etc/systemd/system/update-server.timer
sudo systemctl daemon-reload
sudo systemctl enable --now update-server.timer
