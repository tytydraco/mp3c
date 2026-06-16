#!/usr/bin/env bash

function convert_audio_adts_aac() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.aac"

    [[ "$input_file" == "$output_file" ]] && return 0

    local ffmpeg_args=(
        -n
        -f adts
        -c:a aac
        -b:a 256k
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_audio_adts_aac
