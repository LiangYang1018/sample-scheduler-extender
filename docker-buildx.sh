#!/bin/bash

group=nest
registry=liam1018
image=sample-scheduler-extender



build(){
  docker buildx create --use --name ${group} --node ${group}0
  docker buildx build  --platform=linux/arm64,linux/amd64   \
    -f Dockerfile \
    --push \
    -t ${registry}/${image}:latest \
    .
}

main(){
  build $@
}

main $@
