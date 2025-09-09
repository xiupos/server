#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

docker compose -f $DIR/docker-compose.yml down
sudo rm -rf $DIR/data

# postgresql
docker-compose -f $DIR/docker-compose.yml up -d db && sleep 5
gunzip -c -d $DIR/backup/pgdumpall.gz > $DIR/pgdumpall
docker-compose -f $DIR/docker-compose.yml exec -T db \
  psql -U $POSTGRES_USER $POSTGRES_DB < $DIR/pgdumpall
rm $DIR/pgdumpall
docker-compose -f $DIR/docker-compose.yml stop db

# redis
sudo tar -C $DIR -zxvf $DIR/backup/redis.tar.gz data/redis

# docker compose -f $DIR/docker-compose.yml up -d
