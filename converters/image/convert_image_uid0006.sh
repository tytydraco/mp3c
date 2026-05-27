#!/usr/bin/env bash

function convert_image_uid0006() {
    [[ -z "${1:-}" ]] && return 1

    local input_file="$1"
    local output_file="${input_file%.*}.uid0006.jpg"

    local convert_args=(
        -interlace none         # Remove interlace.
        -auto-orient            # Rotate if needed.
        -gravity center         # Center within canvas.
        -resize "1340x1340>"    # Contain within size or smaller.
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_uid0006