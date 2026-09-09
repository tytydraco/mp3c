#!/usr/bin/env bash

case "$1" in
    build)
        docker build \
            --no-cache \
            --tag mp3c:latest \
            .
        ;;
    run)
        docker run \
            --rm \
            --name mp3c \
            --interactive \
            --tty \
            mp3c:latest
        ;;
    clean)
        docker image rm mp3c:latest
        ;;
    *)
        echo "Usage: $0 <build|run|clean>"
        exit 1
        ;;
esac