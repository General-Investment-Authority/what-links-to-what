#!/bin/bash

files=`ls *.turtle`
for file in $files
do
	curl -X POST -H 'Content-Type:application/x-turtle' --data-binary @$file http://localhost:9999/blazegraph/sparql
done
