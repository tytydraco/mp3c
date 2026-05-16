#!/usr/bin/env bash

function convert_video_1080p_mkv() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.1080p.mkv"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    local size="'if(gt(ih, iw), -2, 1920)':'if(gt(ih, iw), 1920, -2)'"
    ffmpeg \
        -i "$input_file" \
        -n \
        -f mkv \
        -vf "scale=${size}" \
        -pix_fmt yuv420p \
        -c:v libx264 \
        -c:a copy \
        -fpsmax 60 \
        "$output_file"
}

export -f convert_video_1080p_mkv