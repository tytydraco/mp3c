#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

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
            --user "$(id -u):$(id -g)" \
            -e HOME="$HOME" \
            --name mp3c \
            --interactive \
            --tty \
            --volume "$HOME:$HOME:ro" \
            --volume "$SCRIPT_DIR:/app" \
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