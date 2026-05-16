#!/usr/bin/env bash

function convert_video_1080p_mkv() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.1080p.mkv"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    local size="'if(gt(ih, iw), -2, min(1920, iw))':'if(gt(ih, iw), min(1920, ih), -2)'"
    ffmpeg \
        -i "$input_file" \
        -n \
        -vf "scale=$size:force_divisible_by=2" \
        -pix_fmt yuv420p \
        -c:v libx264 \
        -c:a copy \
        -fpsmax 60 \
        "$output_file"
}

export -f convert_video_1080p_mkv