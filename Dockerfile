FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Bash is required to be the default shell.
RUN ln -sfv /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    imagemagick \
    calibre \
    ffmpeg \
    wine \
    wine64 \
    winbind \
    git

COPY . /app
WORKDIR /app

ENTRYPOINT [ "bash", "main.sh" ]