#!/bin/bash

POL=$1
DATE=$2

if [  -n "${POL}" ]; then
  if [  -n "${DATE}" ]; then
    echo "Looking for all files"
    for f in `ls impervafiles/SecureSphere_Audit_@${POL}_$DATE*`; do
      echo "Proceso a -> $f"
      ./processbackup.sh $f
    done
    echo "Done!"
  else
    echo "You must specify a POLICY"
  fi
else
  echo "You must specify a DATE"
fi
