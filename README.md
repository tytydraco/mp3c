# mp3c

Specialized format converter tools for MP3 players.

# Details

This program converts audio, images, text, and videos to device-specific
formats for optimal playback and quality. Many converters are already
built in [converters](converters), but you may need to create your own
converter if you want optimal playback for a specific device.

# Usage

1. Configure your config in [config.sh](config.sh).
2. Run `./main.sh`.

# Docker

A `Dockerfile` is bundled for dependency management. `docker.sh` can be used to
build the image and start the conversion process. `config.sh` will be
bind-mounted so that the image does not need to be rebuilt when the config
changes. The output folder will be copied to `docker_output`.

- `./docker.sh build`: You only needs to be run once.
- `./docker.sh run`: Executes `main.sh` and starts the program.
- `./docker.sh clean`: Removes the container.

# Credit

- [Patched FFMPEG from fdd4s](https://github.com/fdd4s/portable_music_player_avi_video_converter_tool_2025)
