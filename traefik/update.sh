#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

docker compose -f $DIR/docker-compose.yml pull
docker compose -f $DIR/docker-compose.yml down
docker compose -f $DIR/docker-compose.yml up -d
