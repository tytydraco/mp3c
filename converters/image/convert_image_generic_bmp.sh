#!/usr/bin/env bash

function convert_image_generic_bmp() {
    [[ -z "${1:-}" ]] && return 1

    local name="${NAME:-generic}"
    local width="${WIDTH:-240}"
    local height="${HEIGHT:-320}"

    local input_file="$1"
    local output_file="${input_file%.*}.${name}_${width}x${height}.bmp"

    local size="${width}x${height}"
    local convert_args=(
        -interlace none     # Remove interlace.
        -rotate "-90>"      # Rotate if needed.
        -gravity center     # Center within canvas.
        -background black   # Pad with black.
        -resize "$size"     # Contain within size.
        -extent "$size"     # Use entire lenght.
    )

    convert \
        "$input_file" \
        "${convert_args[@]}" \
        "$output_file"
}

export -f convert_image_generic_bmp