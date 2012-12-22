#!/bin/bash

for file in *.amr
do
    file2=`echo "$file" | sed 's/\.amr/.mp3/'`
    copytimes "$file" "$file2"
done

