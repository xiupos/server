#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

docker-compose -f $DIR/docker-compose.yml down
sudo rm -rf $DIR/data

sudo tar -C $DIR -zxvf $DIR/backup/sharelatex.tar.gz data/sharelatex
sudo tar -C $DIR -zxvf $DIR/backup/db.tar.gz data/db
