#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

# Create backup
mkdir -p $DIR/backup

# postgresql
docker compose -f $DIR/docker-compose.yml exec -T db \
  pg_dumpall -U $POSTGRES_USER | gzip -c > $DIR/backup/pgdumpall.gz
docker compose -f $DIR/docker-compose.yml exec -T db \
  pg_dump -U $POSTGRES_USER -d $POSTGRES_DB | gzip > $DIR/backup/pgdump.sql.gz

# redis
# sudo tar -C $DIR -zcvf backup/redis.tar.gz data/redis
# sudo chown -c xiupos:xiupos $DIR/backup/redis.tar.gz
