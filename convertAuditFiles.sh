#!/bin/bash

DIR=$1

if [ -z "$DIR" ]; then
   echo "Pass as a parameter the folder of the mprv files"
   exit 0
fi

echo "Directory parameter is: $DIR"

chmod +x ./eventCrcConvertor.x

in_files=$( find $DIR/ | egrep "\.crc2event$" | sort )

for in_file in ${in_files}; do
	echo "PROCESSING ${in_file}"
	./eventCrcConvertor.x ${in_file} ${in_file}.csv >& /dev/null
	if [ $? -ne 0 ]; then
		echo "Failed."
		exit 1	
	fi
done

echo "Now Processing each file"

file_index=1

in_files=$( find ./$DIR | egrep "\.crc2event$" | rev | cut -d "/" -f 1 |cut -d '.' -f 2 | rev | sort )

mkdir -p ./$DIR/converted_data
for in_file in ${in_files}; do
	echo "Moving ${in_file} in number ${file_index}"
	mv ./$DIR/${in_file}.csv ./$DIR/converted_data/${file_index}.events.csv >& /dev/null
	mv ./$DIR/${in_file}.csv_ ./$DIR/converted_data/${file_index}.events2.csv >& /dev/null
	mv ./$DIR/${in_file}.crc2event.csv ./$DIR/converted_data/${file_index}.crc2event.csv
	mv ./$DIR/${in_file}.crc2key ./$DIR/converted_data/${file_index}.crc2key.csv >& /dev/null 
	mv ./$DIR/${in_file}.responses ./$DIR/converted_data/${file_index}.responses.csv >& /dev/null
	mv ./$DIR/${in_file}.response_ ./$DIR/converted_data/${file_index}.responses2.csv >& /dev/null
	file_index=$((++file_index))
done

echo "Removing created files"

rm -f ./$DIR/*000000*


echo "Finished processing $DIR."
