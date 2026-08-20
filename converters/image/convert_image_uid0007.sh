#!/usr/bin/env bash

function convert_image_uid0007() {
    [[ -z "$1" ]] && return 1

    local input_file="$1"
    local output_file="${2:-"${input_file%.*}.uid0007.jpg"}"

    local size="128x160"
    local convert_args=(
        -interlace none
        -auto-orient
        -colorspace sRGB
        -strip
        -rotate "-90>"
        -resize "$size^"
        -gravity center
        -extent "$size"
    )

    convert \
        -n \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0007

[[ "${BASH_SOURCE[0]}" == "$0" ]] && convert_image_uid0007 "$@"