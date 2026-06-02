# mp3c

Specialized format converter tools for MP3 players.

# Details

This program converts audio, images, text, and videos to device-specific
formats for optimal playback and quality. Many converters are already
built in [converters](converters), but you may need to create your own
converter if you want optimal playback for a specific device.

# Usage

1. Copy the [example config](config.example.sh) to [config.sh](config.sh).
2. Run `./main.sh`.

# Docker

A `Dockerfile` is bundled for dependency management. `docker.sh` can be used to
build the image and start the conversion process. `config.sh` will be
bind-mounted so that the image does not need to be rebuilt when the config
changes. The output folder will be copied to `docker_out`.

- `./docker.sh build`: Only needs to be run once.
- `./docker.sh run`: Executes `main.sh` and starts the program.
- `./docker.sh clean`: Removes the container.

# YP3 Patch

- [Patched x264 FFMPEG for YP3 chips](https://github.com/tytydraco/ffmpeg-yp3-patch)
- [Open source encoder/muxer for ATJ AVI MJPEG chips](https://github.com/tytydraco/atj-avi-encoder)

# Credit

- [Patched FFMPEG from fdd4s](https://github.com/fdd4s/portable_music_player_avi_video_converter_tool_2025)
