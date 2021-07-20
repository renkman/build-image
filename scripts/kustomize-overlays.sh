#!/bin/bash
path=$1 
if [ -z "$path" ] || [ ! -d "$path" ] 
then 
   echo "Missing or invalid argument PATH" >&2 
   echo "Usage: ./kustomize-overlays.sh PATH [checkimage]" 
   exit 1 
fi 

checkimage=0
if [ "$2" = "checkimage" ]
then
    checkimage=1
fi

overlays="$path/overlays" 

echo "kubectl version:" 
kubectl version --client=true --output=yaml 

echo "kustomize version" 
kustomize version 

exitcode=0 
for overlay in $(ls "$overlays") 
do 
   if [ ! -d "$overlays/$overlay" ] 
   then 
       echo "$overlay is not a directory" >&2 
       exit 2 
   fi
   cwd=$(pwd) 
   echo $(pwd) 
   cd "$overlays/$overlay" 
   echo $(pwd)
   if [ $checkimage -eq 1 ]
   then
    echo "IMAGE_NAME: $IMAGE_NAME" 
    kustomize edit set image "$IMAGE_NAME"=registry.example.com/repository:my-very-fancy-tag
    if [ $? != 0 ]; then 
        exitcode=1 
    fi
    cd "$cwd" 
    echo $(pwd)
  fi
  kubectl kustomize "$overlays/$overlay" | kubeval --ignore-missing-schemas --strict --kubernetes-version 1.19.8
  if [ $? != 0 ]; then
    echo -e "\e[31mError validating $overlays/$overlay\e[0m" >&2
    exitcode=1 
  fi
done 
exit $exitcode
