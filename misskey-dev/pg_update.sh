#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

docker-compose -f $DIR/docker-compose.yml pull
docker-compose -f $DIR/docker-compose.yml down

sudo cp -r $DIR/data/db $DIR/data/db_old
docker-compose -f $DIR/docker-compose.yml up -d db
docker-compose -f $DIR/docker-compose.yml exec db sh -c "
  PGPASSWORD=$POSTGRES_PASSWORD pg_dump --no-owner -x -d $POSTGRES_DB -U $POSTGRES_USER > dump.psql
  PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER $POSTGRES_DB < dump.psql
"
docker-compose -f $DIR/docker-compose.yml down

docker-compose -f $DIR/docker-compose.yml up -d
