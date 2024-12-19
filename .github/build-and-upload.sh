#!/bin/bash

echo "Buidling and pushing nagampere0508/graphhopper-kanto:latest"
./build.sh --push

TAG=`cd graphhopper; git for-each-ref --sort=committerdate refs/tags | sed -n '$s/.*\///p'`
if docker manifest inspect "nagampere0508/graphhopper-kanto:${TAG}" >/dev/null; then 
    echo "No need to push existing version: ${TAG}";
else
    echo "Buidling and pushing nagampere0508/graphhopper-kanto:${TAG}"
    ./build.sh --push "${TAG}"
fi
