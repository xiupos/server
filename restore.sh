#!/bin/bash

SVR_ROOT=`cd $(dirname ${0}) && pwd`
GD_ROOT=/GDrive
BU_ROOT=$GD_ROOT/Data/Server

if [ ! -e $GD_ROOT ]; then
  echo "ERR: There is not GDrive dir."
  echo "Have you mounted it?"
  exit 1
fi

if [ ! -e $BU_ROOT ]; then
  echo "ERR: There is no archive."
  echo "Have you made any backups?"
  exit 1
fi

dirs=()
temp=(${@:-$(ls $SVR_ROOT)})
for i in ${temp[@]}; do
  if [ -e $BU_ROOT/$i ]; then
    dir+=($i)
  fi
done

if [ ${#dir[@]} -eq 0 ]; then
  echo "ERR: There is no backupable dirs."
  echo "Check if the params are correct"
  exit 1
fi

for i in ${dir[@]}; do
  mkdir -p $SVR_ROOT/$i/backup

  echo -n "$BU_ROOT/$i/* -> $SVR_ROOT/$i/backup/ ... "
  cp -rf $BU_ROOT/$i/* $SVR_ROOT/$i/backup/
  echo "done"

  echo -n "$SVR_ROOT/$i/restore.sh ... "
  bash $SVR_ROOT/$i/restore.sh &>/dev/null
  echo "done"
done
