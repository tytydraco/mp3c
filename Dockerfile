FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Bash is required to be the default shell.
RUN ln -sfv /bin/bash /bin/sh

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    imagemagick \
    pandoc \
    ffmpeg \
    wine \
    wine64 \
    winbind \
    wine32:i386

COPY . /app
WORKDIR /app

ENTRYPOINT [ "bash", "main.sh" ]