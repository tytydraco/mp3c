#!/usr/bin/env bash

function convert_audio_mp3() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.mp3"

    [[ "$input_file" == "$output_file" ]] && return 0

    local ffmpeg_args=(
        -n          # Do not replace existing files.
        -f mp3      # MP3 format.
        -q:a 2      # Target transparent quality.
    )

    ffmpeg \
        -i "$input_file" \
        "${ffmpeg_args[@]}" \
        "$output_file"
}

export -f convert_audio_mp3