#!/usr/bin/env bash

function convert_audio_mp3() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.mp3"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    ffmpeg \
        -i "$input_file" \
        -n \
        -f mp3 \
        -q:a 2 \
        "$output_file"
}

export -f convert_audio_mp3