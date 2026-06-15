#!/usr/bin/env bash

function convert_image_uid0001() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0001.jpg"

    local size="240x320"
    local convert_args=(
        -interlace none     # Remove interlace.
        -auto-orient        # Rotate according to EXIF data.
        -rotate "-90>"      # Rotate counter-clockwise if landscape.
        -resize "$size"     # Contain within size.
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0001