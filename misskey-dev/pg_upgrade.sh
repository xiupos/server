#!/bin/bash

DIR=`cd $(dirname ${0}) && pwd`
source $DIR/.config/docker.env

docker-compose -f $DIR/docker-compose.yml pull
docker-compose -f $DIR/docker-compose.yml down

sudo cp -r $DIR/data/db $DIR/data/db_old
docker-compose -f $DIR/docker-compose.pg_upgrade.yml pull
docker-compose -f $DIR/docker-compose.pg_upgrade.yml up -d db-v12
docker-compose -f $DIR/docker-compose.pg_upgrade.yml exec db-v12 sh -c "
  PGPASSWORD=$POSTGRES_PASSWORD pg_dump --no-owner -x -d $POSTGRES_DB -U $POSTGRES_USER > /tmp/pg_upgrade/dump.psql
"
docker-compose -f $DIR/docker-compose.yml down

docker-compose -f $DIR/docker-compose.pg_upgrade.yml up -d db-v15
docker-compose -f $DIR/docker-compose.pg_upgrade.yml exec db-v15 sh -c "
  PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER $POSTGRES_DB < /tmp/pg_upgrade/dump.psql
"
docker-compose -f $DIR/docker-compose.yml down

sudo rm -rf $DIR/data/tmp/

docker-compose -f $DIR/docker-compose.yml up -d
