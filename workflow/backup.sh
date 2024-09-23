#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

# Create backup
mkdir -p $DIR/backup
sudo tar -C $DIR -zcvf backup/data.tar.gz data
