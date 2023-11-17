#!/bin/bash

set -e

DOCKER_IMAGE = "lbg"

cleanup() {
    echo "Cleaning up previous build artefacts"
    sleep 3

    docker rm -f $(docker ps -aq) || true
    docker rmi -f$(docker images) || true
    echo "Cleanup done"
}

build_docker() {
    echo "building docker image"
    sleep 3
    docker build -t $DOCKER_IMAGE .
    }

modify_app() {
    echo "Modifying the app"
    sleep 3
    export PORT=5001
    echo "Modify is done. Port is now set to $PORT"
}

run_docker() {
    echo "echo running docker container"
    sleep 3
    docker run -d -p 80:$PORT -e PORT=$PORT $DOCKER_IMAGE
}

echo "starting the build process"
sleep 3
cleanup
build_docker
modify_docker
build_docker
run_docker
echo "Build process completed successfully"