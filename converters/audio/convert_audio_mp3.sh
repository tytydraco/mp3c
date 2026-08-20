#!/usr/bin/env bash

function convert_audio_mp3() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.mp3"}"

    [[ "$input_file" == "$output_file" ]] && return 0

    local ffmpeg_args=(
        -f mp3
        -ar:a 16000
        -ac:a 1
        -q:a 8
    )

    ffmpeg \
        -nostdin \
        -n \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_audio_mp3

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_audio_mp3 "$@"