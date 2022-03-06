#!/bin/bash

SVR_ROOT=`cd $(dirname ${0}) && pwd`

dirs=()
temp=(${@:-$(ls $SVR_ROOT)})
for i in ${temp[@]}; do
  if [ -e $SVR_ROOT/$i/update.sh ]; then
    dir+=($i)
  fi
done

if [ ${#dir[@]} -eq 0 ]; then
  echo "ERR: There is no updatable dirs."
  echo "Check if the params are correct"
  exit 1
fi

for i in ${dir[@]}; do
  echo -n "$SVR_ROOT/$i/update.sh ... "
  bash $SVR_ROOT/$i/update.sh &>/dev/null
  echo "done"
done
