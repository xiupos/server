#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

# Create backup
mkdir -p $DIR/backup
docker-compose -f $DIR/docker-compose.yml exec -T db \
  pg_dumpall -U $POSTGRES_USER | gzip -c > $DIR/backup/pgdumpall.gz
