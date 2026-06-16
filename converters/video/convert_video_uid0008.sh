#!/usr/bin/env bash

function convert_video_uid0008() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0008.mp4"

    local size="'if(gte(iw/ih, 4/3), -2, min(640, iw))':'if(gte(iw/ih, 4/3), min(480, ih), -2)'"                                    # Contain to display size, but allow excess for the crop to trim.
    local crop="'min(640, iw)':'min(480, ih)'"                                                                                      # Crop to display size or smaller.
    local ffmpeg_args=(
        -n                                                                                                                          # Do not replace existing files.
        -f mp4                                                                                                                      # MP4 container.
        -map 0:v:0                                                                                                                  # Choose first video stream.
        -map 0:a:0?                                                                                                                 # Choose first audio stream, if it exists.
        -c:v libx264                                                                                                                # H.264 codec.
        -filter:v "transpose=cclock:passthrough=landscape,scale=$size:force_divisible_by=2:in_range=auto:out_range=tv,crop=$crop"   # Pre-rotate counter-clockwise if portrait, contain within size, ensure even lengths, crop, ensure TV range pixel format.
        -pix_fmt:v yuv420p                                                                                                          # TV range pixel format.
        -crf:v 32                                                                                                                   # Target improved compression.
        -fpsmax:v 30                                                                                                                # Match original source FPS.
        -c:a aac                                                                                                                    # AAC audio codec.
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0008