#!/usr/bin/env bash

function convert_image_ruizu_x52_bmp() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.ruizu_x52.bmp"

    if [[ "$input_file" == "$output_file" ]]; then
        echo "[$0] Input is already converted: $input_file"
        return 0
    fi

    convert \
        "$input_file" \
        -interlace none \
        -resize 128x \
        -gravity center \
        -background black \
        -extent 128x128 \
        "$output_file"
}

export -f convert_image_ruizu_x52_bmp