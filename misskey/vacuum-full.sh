#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

docker compose -f $DIR/docker-compose.yml up -d
docker compose -f $DIR/docker-compose.yml down misskey
docker compose -f $DIR/docker-compose.yml exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -c "vacuum full;"
docker compose -f $DIR/docker-compose.yml up -d
