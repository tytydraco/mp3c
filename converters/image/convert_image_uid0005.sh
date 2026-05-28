#!/usr/bin/env bash

function convert_image_uid0005() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0005.jpg"

    local size="128x128"
    local convert_args=(
        -interlace none     # Remove interlace.
        -rotate "-90>"      # Rotate if needed.
        -gravity center     # Center within canvas.
        -background black   # Pad with black.
        -resize "$size"     # Contain within size.
        -extent "$size"     # Full canvas size.
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0005