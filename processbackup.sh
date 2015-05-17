#!/bin/bash

FILENAME=$1

if [ ! -d temp ]; then
  mkdir temp
fi

if [  -n "${FILENAME}" ]; then
  if [ -f $FILENAME ]; then

      NAME=$(basename $1)
    
      echo "Intento procesar a $FILENAME"
      
      if [ ! -d temp ]; then
        echo "Creo la carpeta $NAME-dir"
        mkdir $NAME-dir
      else
        echo "Borro lo que exista en $NAME-dir"
        rm -rf $NAME-dir/*
      fi
      
      echo "Copio a tmp al archivo $NAME"
      cp $FILENAME ./temp/
      
      echo "Ejecuto el packagertool.jar"
      java -jar packagertool.jar -unpack -source temp/$NAME -target $NAME-dir/
      
      echo "Ahora ejecuto el convertAuditFiles"
      
      ./convertAuditFiles.sh $NAME-dir
      
      echo "Ahora ejecuto el joinfiles.rb"
      
      ruby joinfiles.rb $NAME-dir/ 1>/tmp/$NAME.log & #lo hago en background, tendria que redirigir el output
      
      rm temp/$NAME* 2>/dev/null
    else
      echo "El archivo no existe!"
    fi
else
  echo "Se debe enviar un archivo como parametro"
fi
