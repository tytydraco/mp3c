#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

case "$1" in
    build)
        docker build \
            --no-cache \
            --tag mp3c:latest \
            .
        ;;
    run)
        docker run \
            --name mp3c \
            --interactive \
            --tty \
            --volume "$SCRIPT_DIR/config.sh:/app/config.sh:ro" \
            --volume "$SCRIPT_DIR/working/:/app/working/:rw" \
            mp3c:latest
        docker rm -f mp3c
        ;;
    clean)
        docker image rm mp3c:latest
        ;;
    *)
        echo "Usage: $0 <build|run|clean>"
        exit 1
        ;;
esac