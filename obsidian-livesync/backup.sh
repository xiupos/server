#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

# Create backup
mkdir -p $DIR/backup
sudo tar -C $DIR -zcvf $DIR/backup/couchdb.tar.gz data/couchdb
