#!/bin/bash

path=$1 
if [ -z "$path" ] || [ ! -d "$path" ] 
then 
   echo "Missing or invalid argument PATH" >&2 
   echo "Usage: ./kustomize-projects.sh PATH" 
   exit 1 
fi 

exitcode=0
echo "Find kustomize manifest directories"
manifest_dirs=$(find "$path" -type d -name manifests)
for manifest_dir in $manifest_dirs
do
    echo "Check $manifest_dir"
    /kustomize-overlays.sh "$manifest_dir"
    code=$?
    if [ $code -ne 0 ]
    then
        exitcode=$code
    fi
done

exit $exitcode
