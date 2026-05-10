#!/usr/bin/env bash

function convert_image_agptek_m6_jpg() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.agptek_m6.jpg"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    convert \
        "$input_file" \
        -interlace none \
        -resize 320x \
        "$output_file"
}

export -f convert_image_agptek_m6_jpg