#!/bin/bash

for f in `ls impervafiles`; do
  echo "processbackup.sh: Proceso a -> $f"
  FILENAME="impervafiles/$f"
  
  if [ ! -d temp ]; then
    mkdir temp
  fi
  
  if [ ! -d processed ]; then
    mkdir processed
  fi
  
  if [  -n "${FILENAME}" ]; then
    if [ -f $FILENAME ]; then
  
        NAME=$(basename $f)
      
        echo "processbackup.sh: Trying to rpocess $FILENAME"
        
        if [ ! -d $NAME-dir ]; then
          echo "processbackup.sh: Creating folder $NAME-dir"
          mkdir $NAME-dir
        else
          echo "processbackup.sh: Deleting folder $NAME-dir"
          rm -rf $NAME-dir/*
        fi
        
        echo "processbackup.sh: Copying to ./tmp file $NAME"
        cp $FILENAME ./temp/
        
        echo "processbackup.sh: Executing packagertool.jar"
        java -jar packagertool.jar -unpack -source temp/$NAME -target $NAME-dir/
        
        echo "processbackup.sh: Now running convertAuditFiles.sh"
        
        ./convertAuditFiles.sh $NAME-dir
        
        echo "processbackup.sh: Now running joinfiles.rb"
        
        ruby joinfiles.rb $NAME-dir/
        
        rm temp/$NAME* 2>/dev/null
      else
        echo "processbackup.sh: The file $FILENAME does not exist!"
      fi
  else
    echo "You must send a file as an argument"
  fi
done
echo "processbackup.sh: Done!"
