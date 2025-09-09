#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source .config/docker.env

docker compose -f $DIR/docker-compose.yml up -d
docker compose -f $DIR/docker-compose.yml misskey down
docker compose -f $DIR/docker-compose.yml exec db psql -U $POSTGRES_USER -d $POSTGRES_DB -c "vacuum full;"
docker compose -f $DIR/docker-compose.yml up -d
