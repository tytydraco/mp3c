#!/usr/bin/env bash

function convert_image_uid0001() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0001.jpg"

    local size="240x288"
    local convert_args=(
        -interlace none     # Remove interlace.
        -rotate "-90>"      # Rotate if needed.
        -gravity center     # Center within canvas.
        -background black   # Pad with black.
        -resize "$size"     # Contain within size.
        -extent "$size"     # Use entire length.
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0001