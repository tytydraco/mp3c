#!/usr/bin/env bash

function convert_video_uid0006() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0006.mp4"

    local size="'if(gt(iw, ih), min(1340, iw), -2)':'if(gt(iw, ih), -2, min(800, ih))'"
    local ffmpeg_args=(
        -n
        -f mp4
        -map 0:v:0
        -map 0:a:0?
        -c:v libx264
        -filter:v
        "
            scale=$size:force_original_aspect_ratio=decrease:force_divisible_by=2:in_range=auto:out_range=tv
        "
        -pix_fmt:v yuv420p
        -crf:v 32
        -fpsmax:v 30
        -c:a aac
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_video_uid0006
