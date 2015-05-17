#!/bin/bash

for f in `ls impervafiles`; do
  echo "Proceso a -> $f"
  ./processbackup.sh impervafiles/$f
done
echo "Done!"
