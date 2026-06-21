# mp3c

Specialized format converter tools for MP3 players.

# Details

This program converts audio, images, text, and videos to device-specific
formats for optimal playback and quality. Many converters are already
built in [converters](converters), but you may need to create your own
converter if you want optimal playback for a specific device.

# Devices

A limiting criteria for device selecting is necessary to prevent redundancy.

> mp3c targets constrained media devices where content must be preprocessed into the device's preferred viewing orientation and resolution. Devices that already provide robust rotation, scaling, zooming, or cropping functionality are generally out of scope, though some exceptions may apply when it makes sense. We aim to avoid writing multi-case operations and instead streamline into one consistent pipeline.

# General Conversion Rules

- If both portrait and orientations for an image or video display correctly, choose the device's screen orientation (i.e., portrait player receives a portrait image, even if a landscape image work, too).
- If rotation is needed or ambiguous, use the device's preferred rotation for the content. This can be determined by playing a video, or by viewing an image which has the opposite orientation of the device's screen. Most ATJ devices prefer counter-clockwise rotation, while most SL devices prefer clockwise rotation, but the rule is not always true, especially for landscape devices. If the device has a square screen, do not rotate.
- Always ensure the content fills the entire screen (crop).

# Usage

1. Copy the [example config](config.example.sh) to [config.sh](config.sh).
2. Run `./main.sh`.

# Docker

A `Dockerfile` is bundled for dependency management. `docker.sh` can be used to
build the image and start the conversion process. `config.sh` will be
bind-mounted so that the image does not need to be rebuilt when the config
changes. The working folder is shared with the docker container.

- `./docker.sh build`: Only needs to be run once.
- `./docker.sh run`: Executes `main.sh` and starts the program.
- `./docker.sh clean`: Removes the container.

# YP3 Patch

- [Patched x264 FFMPEG for YP3 chips](https://github.com/tytydraco/ffmpeg-yp3-patch)
- [Open source encoder/muxer for ATJ AVI MJPEG chips](https://github.com/tytydraco/atj-avi-encoder)

# Credit

- [Patched FFMPEG from fdd4s](https://github.com/fdd4s/portable_music_player_avi_video_converter_tool_2025)
