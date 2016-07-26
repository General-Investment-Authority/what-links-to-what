#!/bin/bash

files=`ls *.turtle`
for file in $files
do
	tar -czvf $file.tar.gz $file
done
