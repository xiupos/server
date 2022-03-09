#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

# Create backup
mkdir -p $DIR/backup
sudo tar -C $DIR -zcvf $DIR/backup/taskcafe.tar.gz data/taskcafe
sudo tar -C $DIR -zcvf $DIR/backup/db.tar.gz data/db
