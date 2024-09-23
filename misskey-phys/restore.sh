#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

docker compose -f $DIR/docker compose.yml down
sudo rm -rf $DIR/data

sudo tar -C $DIR -zxvf $DIR/backup/data.tar.gz data

# docker compose -f $DIR/docker compose.yml up -d
