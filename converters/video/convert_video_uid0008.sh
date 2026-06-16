#!/usr/bin/env bash

function convert_video_uid0008() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0008.mp4"

    local size="'if(gte(iw/ih, 4/3), -2, min(640, iw))':'if(gte(iw/ih, 4/3), min(480, ih), -2)'"
    local crop="'min(640, iw)':'min(480, ih)'"
    local ffmpeg_args=(
        -n
        -f mp4
        -map 0:v:0
        -map 0:a:0?
        -c:v libx264
        -filter:v
        "
            transpose=cclock:passthrough=landscape,
            scale=$size:force_divisible_by=2:in_range=auto:out_range=tv,
            crop=$crop
        "
        -pix_fmt:v yuv420p
        -crf:v 36
        -fpsmax:v 30
        -c:a aac
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0008
