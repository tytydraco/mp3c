#!/usr/bin/env bash

function convert_image_uid0008() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0008.jpg"

    local convert_args=(
        -interlace none     # Remove interlace.
        -rotate "-90<"      # Rotate if needed.
        -resize "640x480>"  # Contain within size.
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0008