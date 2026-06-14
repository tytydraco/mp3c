#!/usr/bin/env bash

function convert_video_uid0008() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0008.mp4"

    local size="'if(gt(ih, iw), -2, min(640, iw))':'if(gt(ih, iw), min(480, ih), -2)'"
    local ffmpeg_args=(
        -n                                                                                                              # Do not replace existing files.
        -f mp4                                                                                                          # MP4 container.
        -map 0:v:0                                                                                                      # Choose first video stream.
        -map 0:a:0?                                                                                                     # Choose first audio stream, if it exists.
        -c:v libx264                                                                                                    # H.264 codec.
        -filter:v "scale=$size:force_original_aspect_ratio=decrease:force_divisible_by=2:in_range=auto:out_range=tv"    # Contain within size, preserve aspect ratio, ensure even lengths, ensure TV range pixel format.
        -pix_fmt:v yuv420p                                                                                              # TV range pixel format.
        -crf:v 32                                                                                                       # Target improved compression.
        -fpsmax:v 30                                                                                                    # Match original source FPS.
        -c:a aac                                                                                                        # AAC audio codec.
        -profile:a aac_low                                                                                              # AAC low profile.
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0008