#!/bin/bash
echo "stopping previous running image"
prevImage=docker ps | grep 80/tcp | awk '{print $1}'
if [[ ! -z "$prevImage"]]
then
docker stop $prevImage
fi
echo "building image"
docker build ./ --tag simple
echo "running image"
docker run -d -p 80:80 simple
echo "done"