#!/bin/bash

SVR_ROOT=`cd $(dirname ${0}) && pwd`
GD_ROOT=/GDrive
BU_ROOT=$GD_ROOT/Data/Server

if [ ! -e $GD_ROOT ]; then
  echo "ERR: There is not GDrive dir."
  echo "Have you mounted it?"
  exit 1
fi

dirs=()
temp=(${@:-$(ls $SVR_ROOT)})
for i in ${temp[@]}; do
  if [ -e $SVR_ROOT/$i/backup.sh ]; then
    dir+=($i)
  fi
done

if [ ${#dir[@]} -eq 0 ]; then
  echo "ERR: There is no backupable dirs."
  echo "Check if the params are correct"
  exit 1
fi

mkdir -p $BU_ROOT
for i in ${dir[@]}; do
  echo -n "$SVR_ROOT/$i/backup.sh ... "
  bash $SVR_ROOT/$i/backup.sh &>/dev/null
  echo "done"

  mkdir -p $BU_ROOT/$i

  echo -n "$SVR_ROOT/$i/backup/* -> $BU_ROOT/$i/ ... "
  cp -rf $SVR_ROOT/$i/backup/* $BU_ROOT/$i/
  echo "done"
done
