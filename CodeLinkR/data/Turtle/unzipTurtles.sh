#!/bin/bash

files=`ls *.turtle.tar.gz`
for file in $files
do
        tar -xzvf $file
done

