#!/bin/bash

files=`ls *.turtle`
for file in $files
do
	# only create zip if it doesn't exist
	if [ ! -f $file.tar.gz ]; then
		tar -czvf $file.tar.gz $file
	fi
done
