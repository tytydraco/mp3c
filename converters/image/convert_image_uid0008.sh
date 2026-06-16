#!/usr/bin/env bash

function convert_image_uid0008() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0008.jpg"

    local size="640x480"
    local convert_args=(
        -interlace none
        -auto-orient
        -rotate "-90<"
        -resize "$size^>"
        -gravity center
        -extent "$size<"
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0008
