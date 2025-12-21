#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`

docker compose -f $DIR/compose.yml pull
docker compose -f $DIR/compose.yml down
docker compose -f $DIR/compose.yml up -d
